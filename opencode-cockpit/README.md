# opencode-cockpit statusline — design notes

Config lives in `config.json`, the hand-drawn segments in `statusline.mjs`, and `preview.sh`
renders either without restarting OpenCode. This file is the reasoning, kept out of `config.json`
for the reason in the fourth section.

## The line

Array order is **display** order, left to right. **Priority is the sacrifice order**, and the two
are independent — a line does not wrap, it drops its lowest-priority segments until it fits.

```
◆ claude-opus-5·⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀ 43%·⧉ 85.2k tok·▸ src·⑂ feature/checkout·± +42 / -7
└────── 98 ───────────────┘         └ 65 ┘ └──── 92 / 93 / 94 ────────┘
└───────────── left ─────────────┘   └ middle ┘ └────────── right ─────────┘
```

| | segment | draws | prio |
|---|---|---|---|
| **left** | `model` | `◆ claude-opus-5` | 98 |
| | `session.status` | `working`, `retry 2 in 5s` | 88 |
| | `bar` | the braille gauge (custom) | 96 |
| **middle** | `filling` | `+1.2%/m 48m left` (custom) | 75 |
| | `tokens` | `⧉ 85.2k tok` | 65 |
| | `todo` | `▤ 2/5 todo` | 60 |
| | `rate` | `$0.42/min` (custom) | 40 |
| **right** | `cwd` | `▸ src` | 92 |
| | `git.branch` | `⑂ feature/checkout` | 93 |
| | `git.diff` | `± +42 / -7` | 94 |

The git group sits on the right as one block so it stays in one place, and it carries high
priority (92–94) because it is meant to be readable at all times. The middle segments are the
expendable ones.

## At 80 columns, `tokens` and `todo` cannot both fit

Measured, not guessed:

| separator | bar | drawn in `working` | dropped |
|---|---|---|---|
| `" │ "` | 10 | model, bar, cwd, branch, diff | 2 |
| `"·"` | 10 | model, bar, **tokens**, cwd, branch, diff | 1 |
| `"·"` | 10, **no `tokens`** | model, bar, **todo**, cwd, branch, diff | **0** |

**`·` instead of `" │ "` is not cosmetic.** Nine separators at three cells each is 27 columns; at
one cell it is 9. That is the whole difference between six segments fitting and seven.

The shipped config keeps `tokens`, so **`todo` is the casualty** — lowest priority of the three
middle segments, dropped from a working session. Deleting one line gets it back:

```jsonc
{ "type": "tokens", "priority": 65 }   ← delete this
```

That costs nothing real: OpenCode's own footer already shows `119.8K (11%)`, so `tokens` is the
one segment here that is a confirmed second copy. Lever order when the line is too full: drop a
duplicate first, then shorten the gauge (`"width": 8` buys two columns), then widen the terminal.

## The braille gauge

Each braille cell carries two dots, so a ten-cell gauge resolves twenty steps rather than ten.
`⣿` is both dots, `⡇` the left one only, `⠀` empty. Filled cells take `text` — the theme's own
foreground, so it follows whatever theme is running rather than being a literal white — and empty
ones take `border`, never `panel` (`panel` is the panel's own colour, so a track drawn in it is
invisible on most themes).

Adapted from `examples/gallery.ts`'s `barBraille`, which draws the whole bar in one `accent` tone.
Splitting it into two runs is what lets fill and track differ.

**Why a module and not the built-in `context` segment:**

- `{ "type": "context", "style": "gradient" }` colours every filled cell with `gradient(t)` — green
  while there is room, amber as it tightens, red when nearly gone. Good default, wrong here.
- `SegmentConfig.color` is no way out either. `dist/core/segments.js:138` — a colour named on the
  segment "overrides every run in it, icon included" — so the track would be whitened too and the
  gauge would stop reading as a gauge.

The gauge **disappears entirely** when the model in play declares no context window, rather than
showing a percentage against an invented denominator. Three of the six preview states draw nothing
for exactly that reason (`fresh`, `unpriced`, `empty`), and that is correct.

The other seven shipped gauges — `barSolid`, `barFine`, `barSteps`, `barPaint`, `barFilled`,
`barGradient`, `barSplit` — are in `examples/gallery.ts` if this one is ever wrong. The package's
own design skill argues `░` "reads as floating gaps" and that a solid `█` track in `border` tone is
the correct form, so `barSolid` is a fair thing to try next.

## `filling` and `rate` need history, and a guard

A slope does not exist in any single reading, so both accumulate samples between ticks: one per
second, thirty kept. Ported from `examples/bottom.ts` with one fix — **the buffer is cleared when
the session id changes.** The reference does not do this, and the module is loaded once at plugin
setup and then called on every repaint for the life of the process, so without the guard the first
seconds of a new session compute a slope across two unrelated conversations and report a rate of
change that never happened.

Both are silent until there is genuinely something to say: `filling` below 0.05 %/min, `rate` on an
unpriced provider, either of them with too short a span.

## The module has no imports, and that is load-bearing

`statusline.mjs` inlines `contextUsed`, `contextRatio` and `percent` verbatim from the package
rather than importing them from `@opencode-cockpit/status/segment`:

- The loader tries a bare `import()` first, and only falls back to rewriting the authoring
  specifier when that fails.
- **The fallback uses `Bun.resolveSync`, `Bun.file` and `Bun.write`** (`dist/core/custom.js:73`).
- So a module that imports the authoring specifier loads in the TUI (Bun) and **fails in
  `preview.sh` (node)**, and a module that fails to load puts a `⚠` row on the line itself.

With no imports the first `import()` succeeds in both runtimes, so what the preview checks is the
same file the TUI loads. The file is `.mjs` because node treats a bare `.js` as CommonJS unless the
nearest `package.json` sets `"type": "module"`, and this directory has no `package.json`.

The cost: three functions to keep in step if the package changes its definitions.
`contextRatio`'s contract — `undefined` when no window was declared, which is what makes the gauge
vanish rather than lie — is the part that must not drift.

## `config.json` must be strictly valid JSON

`dist/core/config.js:44`:

```js
export function readStatusFile(path) {
  if (!existsSync(path)) return {};
  try {
    return asStatusConfig(JSON.parse(readFileSync(path, "utf8")));
  } catch { return {}; }
}
```

A `//` comment does not raise an error. It makes the whole config vanish and the stock default line
come back, with nothing in the log. The reasoning therefore lives here.

## Do not set `padding*` in this config

Setting `paddingBottom: 0` makes the whole line **invisible in the TUI** while `preview.sh` keeps
rendering it perfectly.

`dist/core/config.js:212`:

```js
const PADDING = {
  // OpenCode's footer indents three columns, and a line hard against the bottom of the window
  // reads as clipped, so this one keeps a row clear underneath it.
  bottom: { left: 3, right: 2, top: 0, bottom: 1 },
  ...
}
```

`paddingBottom: 1` is the row that stops the line being clipped off the bottom edge. Zero it and
the line is drawn into a zero-height container. `paddingLeft: 3` / `paddingRight: 2` line it up
with the prompt's own furniture — which is 5 of the 80 columns.

## What `preview.sh` can and cannot tell you

```sh
sh ~/.config/opencode-cockpit/preview.sh              # all six states at 80 cols
sh ~/.config/opencode-cockpit/preview.sh --debug      # mark segments that drew nothing
sh ~/.config/opencode-cockpit/preview.sh --state full # fresh|working|full|unpriced|retrying|empty
sh ~/.config/opencode-cockpit/preview.sh --watch     # redraw on every save
WIDTH=120 sh ~/.config/opencode-cockpit/preview.sh   # a different width
```

It runs the package's own preview CLI out of **OpenCode's own plugin cache**, so it always renders
the exact copy the TUI loads. The package declares `engines.bun >= 1.3.5`, which this box does not
have; it runs fine under plain `node`.

Three limits, all learned the hard way:

1. **It does not model vertical padding.** It proves the *segments* are right — order, priority,
   width, what stays silent — and proves nothing about *placement*. Padding and clipping can only
   be confirmed by restarting OpenCode and looking.
2. **`--debug` drop counts are meaningless.** Debug mode draws a placeholder for every silent
   segment, which lengthens the line and drops more of it. Use `--debug` to see *which* segments
   have nothing to say, never to count drops.
3. **`--config` does not work under node** (`Bun.file` at `dist/cli/preview.js:43`). To test a
   variant, write it to the real `config.json`, run, and restore.

## No hot reload

`dist/tui/index.js`:

```js
:40  const config = loadStatusConfig(directory, rawOptions)   // once, at plugin setup
:74  const lines  = resolveLines(config)                      // frozen
:94  createMemo(() => buildSegments(store.context(), ...))    // per frame — snapshot only
```

The line's **data** updates every frame (tokens, todo, diff, timer, retry countdown all move live).
Changing **which segments exist**, or their priority, width or style, needs a restart. That is what
`preview.sh` is for — it turns a restart into a one-second check.

## Cut, and why

- **`diagnostics`.** Rendered `⚠ context7, gh_grep +2` — a false positive; `opencode mcp list`
  reports both as `connected`. Two reasons it cannot be trusted here anyway:
  1. It flags on any status outside `{connected, ready, ok, running, active}` (`HEALTHY` in
     `dist/core/context.js`), and its snapshot can catch a server mid-startup.
  2. **It could never clear.** `time` and `sequential-thinking` are `disabled: true` in
     `opencode.jsonc` *and* genuinely broken — `@modelcontextprotocol/server-time` 404s, and
     `mcp-server-sequential-thinking` is not found (exit 127). A permanently lit warning is noise,
     and noise on a 24-row screen costs more than the signal is worth.
- **The `cache / in / out` breakdown** (`tk 65.2k │ cache 60.8k │ in 4.1k │ out 81`). Four columns
  to describe one gauge that is already there.
- **`cost` and `session.time`.** `cost` is the footer already showing spend, and is silent on a
  provider with no declared prices — which is this one. `session.time` is real but low value next
  to everything else.
- **`cwd`, `git.branch`, `model` were originally rejected as footer/prompt duplicates** and are now
  on the line anyway, on request. The reasoning was that a second copy of a fact adds nothing; the
  counter is that a compact right-hand block is easier to read at a glance than one fact in each
  corner of the window.
- **`cached`** (`⇄87% cached`) — a rate-limit signal worth having if the plan ever bites.

## Adding a segment

The one module here is `statusline.mjs`, referenced by the config's `modules` array and providing
`bar`, `filling` and `rate`. Two things to know before adding another:

- **A module listed in `modules` is loaded at plugin startup even if no segment references it**, and
  a module that fails to load puts a `⚠` row on the line itself. So add a module only alongside the
  segment that uses it.
- **Give it no imports from the authoring specifier**, or `preview.sh` cannot load it and the
  change goes in unverified.

`preview.sh --module <path>` renders one module's segments in isolation, without OpenCode.