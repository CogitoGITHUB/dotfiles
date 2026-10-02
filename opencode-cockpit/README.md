# opencode-cockpit statusline — design notes

Config lives in `config.json` next to this file. `preview.sh` renders it without restarting
OpenCode. This file is the reasoning, kept out of `config.json` for the reason in the first
section.

## The line is one segment

```jsonc
{ "statusline": { "segments": [ { "type": "context", "style": "gradient", "width": 10 } ] } }
```

It draws:

```
◔ ████░░░░░░ 43%
```

Nothing else. Everything else that was tried and cut is listed under **Cut** below.

`◔` is the segment's icon, the ten `█`/`░` cells are the bar, and `43%` is the reading. The
percentage is not a separate segment — all three bar styles (`bar`, `gradient`, `split`) append
it in the same run, and only `style: "percent"` drops the bar for the number. If the bar is ever
wanted without the figure, that needs a custom module, not a config key.

The bar **disappears entirely** when the model in play declares no context window, rather than
showing a percentage against an invented denominator. Three of the six preview states draw
nothing for exactly that reason (`fresh`, `unpriced`, `empty`), and that is correct.

Cell colours are interpolated along a gradient rather than bucketed into three states, so the
bar reads as a measurement. The empty track is drawn in `border` tone — in `panel` tone it would
be the panel's own colour and therefore invisible.

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

A `//` comment does not raise an error. It makes the whole config vanish and the stock default
line come back, with nothing in the log. The reasoning therefore lives here.

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
with the prompt's own furniture.

## `preview.sh` cannot see placement

```sh
sh ~/.config/opencode-cockpit/preview.sh              # all six states at 80 cols
sh ~/.config/opencode-cockpit/preview.sh --debug      # mark segments that drew nothing
sh ~/.config/opencode-cockpit/preview.sh --state full # fresh|working|full|unpriced|retrying|empty
sh ~/.config/opencode-cockpit/preview.sh --watch     # redraw on every save
WIDTH=120 sh ~/.config/opencode-cockpit/preview.sh   # a different width
```

It runs the package's own preview CLI out of **OpenCode's own plugin cache**, so it always
renders the exact copy the TUI loads. The package declares `engines.bun >= 1.3.5`, which this
box does not have; it runs fine under plain `node`.

The limit worth remembering: the preview lays segments out horizontally and **does not model the
surface's vertical padding**. So it proves the *segments* are right — order, priority, width, what
stays silent — and proves nothing about *placement*. Padding, position and clipping can only be
confirmed by restarting OpenCode and looking.

## No hot reload

`dist/tui/index.js`:

```js
:40  const config = loadStatusConfig(directory, rawOptions)   // once, at plugin setup
:74  const lines  = resolveLines(config)                      // frozen
:94  createMemo(() => buildSegments(store.context(), ...))    // per frame — snapshot only
```

The line's **data** updates every frame (tokens, todo, diff, timer, retry countdown all move
live). Changing **which segments exist**, or their priority, width or style, needs a restart.
That is what `preview.sh` is for — it turns a restart into a one-second check.

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
  to describe one bar that is already there.
- **`tokens`, `session.time`, `todo`, `git.diff`, `session.status`.** All real, all removed
  because the line is one bar now. If any comes back, note that `cwd`, `git.branch`, `model` and
  `cost` should **not**: OpenCode's own footer already carries path, branch, token total and
  spend, and its prompt carries agent and model. A second copy of a fact adds nothing.
- **`todo` and `git.diff` specifically** had one genuine argument for them — `cli.json` sets
  `session.sidebar: "hide"`, so OpenCode's own todo block is off screen and they had nowhere else
  to live. That was outweighed by wanting one bar.
- **`headroom`** (custom `+1.2%/m · 48m left`). The best idea that went, and the one worth
  reviving if a compact-time warning is ever wanted: a *figure*, not a moving picture, which is
  the form that does not pull the eye.
- **`cached`** (`⇄87% cached`) and **`burn`** (`$/min`). `burn` is silent unless the provider
  declares prices, and this box talks to OpenCode's own provider, which does not — so it was a
  segment that never drew.

## Adding a custom segment

A TypeScript module at `~/.config/opencode-cockpit/statusline.ts` is loaded and transpiled at
plugin startup **even when no segment references it**, and a module that fails to load puts a
`⚠` row on the line itself. Both are reasons not to keep one lying around unused. Put it in the
config's `modules` array *and* reference it, or keep no module at all — which is the current
state.

`preview.sh --module <path>` renders one module's segments in isolation, without OpenCode.