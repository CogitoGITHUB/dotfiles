/**
 * THROWAWAY DIAGNOSTIC PROBE — safe to delete once its output has been read.
 *
 * Two questions, one restart:
 *
 *   A) Does `api.plugins.list()` expose built-in TUI blocks under an id that
 *      `plugin_enabled` can switch off? If yes, the two lines can be hidden with
 *      a config entry and no code at all.
 *
 *   B) Does contributing to `session_prompt` / `session_prompt_right` put anything on
 *      screen, and does it displace what is already there or sit beside it?
 *
 * Exports the same shape as @opencode-cockpit/status: a single entry that answers to
 * both `tui` (v1) and `setup` (v2), each calling the same async function.
 *
 * ── Why there is no `mode: "replace"` on the registrations below ──
 *
 * It was asked for, and it is not expressible. Verified in the installed types:
 *
 *   @opencode/solid  src/plugins/slot.d.ts:5
 *     export type SolidPlugin<TSlots, TContext> = Plugin<JSX.Element, TSlots, TContext>
 *
 *   @opentui/core    plugins/types.d.ts
 *     export interface Plugin<TNode, TSlots, TContext> {
 *       id: string; order?: number; setup?; dispose?;
 *       slots: { [K in keyof TSlots]?: SlotRenderer<TNode, TSlots[K], TContext> }   ← fn only
 *     }
 *
 *   @opentui/core    plugins/registry.d.ts
 *     register(plugin: Plugin<...>): () => void      ← no mode parameter
 *     resolve<K>(slot: K): Array<SlotRenderer<...>>  ← always a list, ordered by `order`
 *
 * `SlotMode = "append" | "replace" | "single_winner"` is real, but it is declared on the
 * *consumer* side — `SolidSlotProps` and `SolidBoundSlotProps` both carry
 * `{ name; mode?: SlotMode; children? }`. That is the host's own `<Slot name=... mode=...>`
 * call. A plugin contributing to a slot passes a bare renderer function and has no way to
 * say how the host should resolve it, so the host's choice stands and this contribution
 * takes whatever the default is.
 *
 * So B cannot test "does replace work". What it can actually establish, which is the
 * question that matters: whether these slots are rendered at all, and whether a plugin
 * contribution lands beside the built-in lines or in place of them.
 *
 * Also note `id` is deliberately absent from the `api.slots.register(...)` argument:
 * `TuiSlotPlugin` is `Omit<SlotCore, "id"> & { id?: never }` — the registry assigns it.
 */

import { writeFileSync } from "node:fs"

const PLUGINS_OUT = "/tmp/oc-probe-plugins.json"
const ERROR_OUT = "/tmp/oc-probe-error.txt"

const notes = []

function fail(where, err) {
  const text = err && err.stack ? err.stack : String(err)
  notes.push(`=== ${where} ===\n${text}`)
  try {
    writeFileSync(ERROR_OUT, notes.join("\n\n") + "\n")
  } catch {
    // Nothing more can be done; part A's own output file is the fallback signal.
  }
}

/** A visible marker as a renderable node, via the same runtime the host uses. */
async function marker(text) {
  const solid = await import("solid-js")
  const opentui = await import("@opentui/core")
  return solid.createComponent(opentui.Text, { children: text })
}

async function probe(api) {
  // ── A: every plugin the host knows about, plus the TUI config it resolved ──────────
  // Runs first and independently: if the slot work below throws, this file still exists.
  let plugins = null
  let tuiConfig = null

  try {
    plugins = api.plugins.list()
  } catch (err) {
    fail("A: api.plugins.list()", err)
  }

  try {
    const c = api.tuiConfig
    tuiConfig = {
      plugin: c?.plugin ?? null,
      plugin_enabled: c?.plugin_enabled ?? null,
      theme: c?.theme ?? null,
    }
  } catch (err) {
    fail("A: api.tuiConfig", err)
  }

  try {
    writeFileSync(
      PLUGINS_OUT,
      JSON.stringify(
        {
          probe: "opencode-slot-probe",
          note: "plugins[].source is 'file' | 'npm' | 'internal' (tui.d.ts:420). Anything not file/npm is a candidate for plugin_enabled.",
          plugins,
          tuiConfig,
        },
        null,
        2,
      ),
    )
  } catch (err) {
    fail("A: write " + PLUGINS_OUT, err)
  }

  // ── B: does contributing to these slots put anything on screen? ─────────────────────
  try {
    const replacement = await marker("PROBE-REPLACED")
    const right = await marker("PROBE-RIGHT")

    api.slots.register({
      slots: {
        session_prompt: () => replacement,
        session_prompt_right: () => right,
      },
    })
  } catch (err) {
    fail("B: api.slots.register on session_prompt / session_prompt_right", err)
  }
}

/** v1 calls `tui`, v2 calls `setup`; both run the same body. */
export default {
  tui: (api) => probe(api),
  setup: (api) => probe(api),
}