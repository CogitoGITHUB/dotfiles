/**
 * The context window as a bar whose fill is the theme's own foreground.
 *
 * Why this is a module and not `{ "type": "context", "style": "gradient" }`:
 *
 *   - The built-in colours every filled cell with `gradient(t)` — green while there is room,
 *     amber as it tightens, red when it is nearly gone. Reasonable default, not what was
 *     wanted here.
 *   - `SegmentConfig.color` is no way out: a colour named on the segment overrides *every* run
 *     in it (`dist/core/segments.js:138` — "overrides every run in it, icon included"), so the
 *     empty track would be whitened too and the bar would stop reading as a bar.
 *
 * So the gauge is drawn here, where the fill and the track can be told apart.
 *
 * Two deliberate choices:
 *   - The fill is the `text` tone, not a literal white, so it follows whatever theme is running.
 *     A hex here would be the first thing that made the line look bolted on.
 *   - The track is `border` tone, never `panel` — `panel` is the panel's own colour, so a track
 *     drawn in it is invisible on most themes.
 *
 * ## On the missing imports
 *
 * `contextUsed`, `contextRatio` and `percent` are inlined verbatim from the package
 * (`dist/core/context.js:8-16`, `dist/core/format.js:39-41`) instead of imported from
 * `@opencode-cockpit/status/segment`. That import is the reason this file is `.mjs` and not
 * `.ts`, and the reason it has no imports at all.
 *
 * The loader tries a bare `import()` first and only falls back to rewriting the authoring
 * specifier when that fails — but the fallback uses `Bun.resolveSync`, `Bun.file` and
 * `Bun.write`, so it cannot run under node. A module that imports the authoring specifier
 * therefore loads in the TUI (Bun) and fails in `preview.sh` (node), which means the preview
 * could not verify it. With no imports the first `import()` succeeds in both runtimes, so what
 * gets checked here is the same file the TUI loads.
 *
 * The trade is real and small: three functions to keep in step if the package ever changes its
 * definitions. They are arithmetic over plain fields, and `contextRatio`'s contract — `undefined`
 * when no window was declared, which is what makes the bar disappear instead of showing a
 * confident wrong number — is the part that must not drift.
 */

/** Tokens that occupy the context window right now: everything the model reads back. */
function contextUsed(tokens) {
  if (!tokens) return 0
  return tokens.input + tokens.output + tokens.reasoning + tokens.cache.read + tokens.cache.write
}

/** `undefined` when no context window was declared — a percentage needs a denominator. */
function contextRatio(session) {
  const limit = session?.model?.contextLimit
  if (!limit || limit <= 0 || !session?.tokens) return undefined
  return Math.min(1, contextUsed(session.tokens) / limit)
}

/** No decimal point: the last digit never changes a decision. */
function percent(ratio) {
  return `${Math.round(ratio * 100)}%`
}

export default {
  segments: {
    bar(ctx, config) {
      const ratio = contextRatio(ctx.session)
      // Nothing to say beats a confident wrong number.
      if (ratio === undefined) return undefined

      const width = typeof config.width === "number" ? config.width : 10
      const filled = Math.round(ratio * width)
      const runs = []
      for (let cell = 0; cell < width; cell++) {
        runs.push({ text: "█", tone: cell < filled ? "text" : "border" })
      }
      runs.push({ text: ` ${percent(ratio)}`, tone: "text" })
      return { runs }
    },
  },
}