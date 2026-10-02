# opencode-cockpit statusline — design notes

Config lives in `config.json` next to this file. **That file is parsed with a plain
`JSON.parse` and a `catch { return {} }`** (see `dist/core/config.js`, `readStatusFile`),
so it must be valid JSON. A `//` comment does not error visibly — it makes the whole
config silently vanish and the stock default line comes back. The reasoning lives here
for exactly that reason. `lanes.sh` is the one shell probe the config calls.

## What was cut, and why

The stock default line carries a context bar **and** a token breakdown:

```
▐▊·············▌ 6% │ tk 65.2k │ cache 60.8k │ in 4.1k │ out 81 │ 8m32s │ ⚠ context7, gh_grep +2
```

Both came out:

- **The bar + `tk/cache/in/out`.** A second copy of the percentage OpenCode's own footer
  already carries, on a screen with 80 columns. A context meter is the one thing worth a
  bar — but not when the number beside it is already there and the bar's real value is the
  slope, not the level.
- **`headroom`** (custom: `+1.2%/m · 48m left`) and **`cached`** (`⇄87% cached`) went with
  them. Both only annotated the bar. `headroom` was the better of the two and is the one
  worth reviving if a compact-time warning is ever wanted back — it is a *figure*, not a
  moving picture, which is the form that does not pull the eye.
- **`burn`** (`$/min`) also went. It is silent unless the provider declares prices, and this
  box talks to OpenCode's own provider, which does not — so it was a segment that never
  drew.

## What is left, and the rule behind it

Only what the host does not already say. OpenCode's footer carries path, branch, token
total and spend; its prompt carries agent and model. None of those are repeated here.

| Segment | Why it earns a place |
|---|---|
| `session.status` | The spinner never says *why* it stalled — this says `retry 2 in 5s`. |
| `diagnostics` | Draws only when something is unhealthy. The `⚠ context7, gh_grep` in the default was already worth keeping. |
| `todo` | `cli.json` sets `session.sidebar: "hide"`, so OpenCode's own todo block is not on screen. This had nowhere else to live. |
| `git.diff` | `git diff --shortstat HEAD` — uncommitted, staged and unstaged together. Untracked files are left out: git cannot count lines in a file it has never seen. |
| `session.time` | Elapsed. |
| `lanes` (`lanes.sh`) | Other herdr lanes that are working. Silent when zero, so a solo session's line stays short. |

## Priority is the sacrifice order

A line drops its **lowest**-priority segment until it fits the width. So the numbering is
the order things get thrown away on a narrow screen: `session.time` and `lanes` go before
`todo`, and `diagnostics` survives almost to the end because it only draws when something is
actually broken. At 80 columns nothing should need dropping, but the ordering is what makes
that true rather than accidental.

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
  node /tmp/opencode/preview/node_modules/@opencode-cockpit/status/dist/cli/preview.js --width 80 --debug
  ```
  `--state fresh|working|full|unpriced|retrying|empty` draws one state; no flag draws all
  six. `--debug` marks segments that drew nothing, so a typo and genuinely-missing data stop
  looking identical. The package's CLI wants `bun >=1.3.5` per its `engines`, which this box
  does not have — but it runs fine under `node`.
- `session.status` / `diagnostics` / `todo` / `git.diff` / `session.time` are all built-ins;
  nothing here needs the module, a custom segment, or anything installed beside it.