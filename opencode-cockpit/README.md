# opencode-cockpit statusline — design notes

Config lives in `config.json` next to this file. **That file is parsed with a plain
`JSON.parse` and a `catch { return {} }`** (see `dist/core/config.js`, `readStatusFile`),
so it must be valid JSON. A `//` comment does not error visibly — it makes the whole
config silently vanish and the stock default line comes back. The reasoning lives here
for exactly that reason. `lanes.sh` is the one shell probe the config calls.

## What is on the line, and why

```
◔ ████░░░░░░ 43% │ ⧉ 85.2k tok │ ▤ 2/5 todo │ ± +42 / -7 │ ◷ 2d 15h
```

Verified against the real renderer at this box's actual 80 columns:

```
node /tmp/opencode/preview/node_modules/@opencode-cockpit/status/dist/cli/preview.js --width 80
```

| Segment | Why it earns a place |
|---|---|
| `session.status` | The spinner never says *why* it stalled — this says `retry 2 in 5s`. |
| `context` (gradient, 10) | The capacity instrument. Reads at a glance instead of parsed. Self-hides when the provider declares no window, so no confident wrong number. |
| `tokens` | The absolute total beside the bar. |
| `todo` | `cli.json` sets `session.sidebar: "hide"`, so OpenCode's own todo block is off screen. This had nowhere else to live. |
| `git.diff` | `git diff --shortstat HEAD` — uncommitted, staged and unstaged together. Untracked files are left out: git cannot count lines in a file it has never seen. |
| `session.time` | Elapsed. |
| `lanes` (`lanes.sh`) | Other herdr lanes that are working. Silent when zero, so a solo session's line stays short. |

Not carried: `cwd`, `git.branch`, `model`, `cost` — OpenCode's own footer already shows path,
branch, token total and spend, and its prompt shows agent and model. A second copy of a fact
adds nothing.

## `diagnostics` is removed on purpose

It was rendering `⚠ context7, gh_grep +2`, which is a false positive — `opencode mcp list`
reports both of those as `connected`. Two separate reasons it cannot be trusted here:

1. It flags on any status outside `{connected, ready, ok, running, active}`
   (`HEALTHY` in `dist/core/context.js`), and its snapshot can catch a server mid-startup.
2. **It could never clear anyway.** `time` and `sequential-thinking` are `disabled: true` in
   `opencode.jsonc` *and* genuinely broken (`@modelcontextprotocol/server-time` 404s;
   `mcp-server-sequential-thinking` is not found, exit 127). A warning that is permanently lit
   is noise, and noise on a 24-row screen costs more than the signal is worth.

## Cut, and why

- **The `cache / in / out` breakdown** (`tk 65.2k │ cache 60.8k │ in 4.1k │ out 81`). Four
  columns to describe one bar that is already there. The bar plus the total says the same
  thing in a third of the width.
- **`headroom`** (custom: `+1.2%/m · 48m left`). The best of the ideas that went, and the one
  worth reviving if a compact-time warning is ever wanted — it is a *figure*, not a moving
  picture, which is the form that does not pull the eye.
- **`cached`** (`⇄87% cached`) and **`burn`** (`$/min`). `burn` is silent unless the provider
  declares prices, and this box talks to OpenCode's own provider, which does not — so it was a
  segment that never drew.

## Priority is the sacrifice order

A line drops its **lowest**-priority segment until it fits the width. So the numbering is
the order things get thrown away on a narrow screen: `session.time` and `lanes` go before
`todo`, and `diagnostics` survives almost to the end because it only draws when something is
actually broken. At 80 columns nothing should need dropping, but the ordering is what makes
that true rather than accidental.

## Do not set `padding*` in this config

Setting `paddingBottom: 0` (and left/right/top to 0 for good measure) makes the whole line
**invisible in the TUI** while `preview.sh` keeps rendering it perfectly. Cost: one confused
afternoon.

`dist/core/config.js:212` — the defaults are not cosmetic:

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

**The preview cannot catch this.** The preview CLI lays segments out horizontally and does not
model the surface's vertical padding, so it reported the line as healthy while the TUI was drawing
nothing. This is the general shape of the trap the package's own design skill warns about: a
preview proves the *segments* are right, never that the *placement* is. Anything about padding,
position, or clipping can only be confirmed by restarting OpenCode and looking.

## Notes for later

- **`lanes.sh` interval is 10s, not the 2s default.** Spawning `herdr` + `python3` every 2
  seconds on a phone to learn "0 lanes" is not a trade worth making.
- **Modules are set up but unused.** A TypeScript module at
  `~/.config/opencode-cockpit/statusline.ts` gets loaded and transpiled at startup even when
  no segment references it, and a module that fails to load puts a `⚠` row on the line
  itself. Not worth paying for on a 24-row screen. If a custom segment is ever needed, put
  it in the config's `modules` array *and* reference it.
- **Check it without restarting OpenCode:**
  ```
  sh ~/.config/opencode-cockpit/preview.sh              # all six states at 80 cols
  sh ~/.config/opencode-cockpit/preview.sh --debug      # mark segments that drew nothing
  sh ~/.config/opencode-cockpit/preview.sh --state full # one state
  sh ~/.config/opencode-cockpit/preview.sh --watch     # redraw on every save
  ```
  `--state` takes `fresh|working|full|unpriced|retrying|empty`. `--debug` marks segments
  that drew nothing, so a typo and genuinely-missing data stop looking identical. The script
  runs the package's own preview CLI out of **OpenCode's own plugin cache**, so it always
  renders the exact version the TUI is running. The package declares `engines.bun >= 1.3.5`,
  which this box does not have — it runs fine under plain `node` anyway.

- **There is no hot reload for config.** `dist/tui/index.js:40` calls `loadStatusConfig`
  during plugin setup and line 74 freezes it with `resolveLines`; the per-frame memo rebuilds
  the line from the session snapshot only. So the line's *data* updates every frame (tokens,
  todo, diff, timer, retry countdown all move live), but changing *which segments are there*,
  their priority, width or style needs a restart. That is what `preview.sh` is for — it turns a
  restart into a one-second check.
- `session.status` / `diagnostics` / `todo` / `git.diff` / `session.time` are all built-ins;
  nothing here needs the module, a custom segment, or anything installed beside it.