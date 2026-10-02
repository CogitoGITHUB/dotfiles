/**
 * Removes the agent / model / variant line that sits at the top of the composer
 * ("Orchestrator · Space Bunny Free Personal / OpenCode · max").
 *
 * ── how this was found ──
 *
 * `mini.footer: "hide"` in cli.json removed the interrupt/context line (verified). The
 * agent/model line survived `mini.turn_summary: "hide"`, whose description is "the agent,
 * model, and duration summary **in scrollback**" — a different place.
 *
 * `opencode plugin list` reports only three plugins and none are `internal:`:
 *
 *   -  0.7.1  @opencode-cockpit/status
 *   -  local  ~/.config/opencode/plugin/probe.js
 *   oh-my-opencode-slim  3.0.1  oh-my-opencode-slim
 *
 * so there is no built-in block id for `plugin_enabled` to switch off. That path is closed.
 *
 * What is left is the V2 slot API. From the composer component in the host binary:
 *
 *   c(Ae, s(Wl, { path: "session.composer.top", get input(){ return { sessionID: … } } }))
 *
 * A slot component `Wl` at the very top of the composer box, rendered unconditionally, in
 * exactly the position the line occupies. `Wl`'s definition references `input`, `mode` and
 * `replace`, and `ctx.ui.slot()` is typed as
 *
 *   slot(claim: { render: (input: never) => JSX.Element } & Record<string, unknown>): () => void
 *
 * — the `& Record<string, unknown>` is where `append` / `replace` live. `@opencode-cockpit/client`
 * only ever uses `append` (`dist/host.js:328`, `:448`), so **`replace` on this path is untested**
 * and this plugin is the test.
 *
 * ── v1 of this probe failed twice, for two different reasons ──
 *
 * 1. Exported `{ tui, setup }` with no `id`:
 *      PluginModule.LoadError: Plugin must export a default definition with an id and an
 *      effect or setup function.  SchemaError(Missing key at ["default"]["id"])
 *    The host normalises with `x = "effect" in k ? k : hG(k)` and then reads `x.id`.
 * 2. Used the v1 API. In V2 `setup` receives an Effect context, not a `TuiPluginApi`:
 *      TypeError: undefined is not an object (evaluating 'api.plugins.list')
 *    So there is no `api.plugins` and no `api.slots` here — the v2 surface is `ctx.ui`,
 *    `ctx.keymap`, `ctx.data`, `ctx.storage`, `ctx.theme`, `ctx.location`, `ctx.renderer`.
 *    Also `import("solid-js")` fails from a bare plugin file (`Cannot find package 'solid-js'`)
 *    even though the cockpit package imports it fine — node_modules resolution privilege, not
 *    an opencode feature. Irrelevant here: rendering `null` needs no element at all.
 *
 * `setup` returns its cleanup function, which is what OpenCode calls to dispose the claim.
 */

import { writeFileSync } from "node:fs"

const LOG = "/tmp/oc-probe-log.txt"

function log(text) {
  try {
    writeFileSync(LOG, text + "\n", { flag: "a" })
  } catch {
    // Nothing useful to do if /tmp is unwritable; the visual result is the real signal.
  }
}

async function setup(ctx) {
  log(`--- setup() ran, v2 context ---`)
  log(`ctx keys: ${Object.keys(ctx ?? {}).join(", ") || "(none)"}`)
  log(`ctx.ui keys: ${Object.keys(ctx?.ui ?? {}).join(", ") || "(none)"}`)

  // The fix: claim the top of the composer and render nothing into it.
  const dispose = ctx.ui.slot({
    replace: "session.composer.top",
    render: () => null,
  })
  log(`claimed session.composer.top with replace; dispose is ${typeof dispose}`)

  return dispose
}

/** v1 entry point. Only reached on OpenCode 1.x, where the v2 context does not exist. */
async function tui(api) {
  log(`--- tui() ran, v1 context ---`)
  log(`api keys: ${Object.keys(api ?? {}).join(", ") || "(none)"}`)
}

export default {
  id: "oc-probe",
  setup,
  tui,
}