/**
 * The statusline. One module, four segments, no imports.
 *
 * ## Why any of this is hand-written
 *
 * The built-in `context` segment colours every filled cell with `gradient(t)` — green while
 * there is room, amber as it tightens, red when nearly gone. The fill wanted here is the theme's
 * own foreground. `SegmentConfig.color` is no way out either: `dist/core/segments.js:138` — a
 * colour named on the segment "overrides every run in it, icon included" — so the track would be
 * whitened too and the gauge would stop reading as a gauge. Hence `bar`, drawn here.
 *
 * ## The braille gauge
 *
 * Each braille cell carries two dots, so a ten-cell bar resolves twenty steps instead of ten.
 * `⣿` is both dots, `⡇` the left one only, `⠀` empty. Filled cells take `text` (the theme's
 * foreground, so it follows whatever theme is running) and empty ones `border` — never `panel`,
 * which is the panel's own colour and therefore invisible on most themes.
 *
 * Adapted from `examples/gallery.ts`'s `barBraille`, which draws the whole bar in a single
 * `accent` tone. Splitting it into two runs is what lets the fill and the track differ.
 *
 * ## `filling` and `rate` need history
 *
 * A slope does not exist in any single reading, so both accumulate samples between ticks. Ported
 * from `examples/bottom.ts`, with one fix: **the sample buffer is reset when the session id
 * changes.** The reference does not, and this module is loaded once at plugin setup and then
 * called on every repaint for the life of the process — so without the guard the first seconds of
 * a new session compute a slope across two unrelated conversations, and report a rate of change
 * that did not happen. A confidently wrong figure is worse than no figure.
 *
 * ## On the missing imports
 *
 * `contextUsed`, `contextRatio` and `percent` are inlined verbatim from the package
 * (`dist/core/context.js:8-16`, `dist/core/format.js:39-41`) instead of imported from
 * `@opencode-cockpit/status/segment`. That import is load-bearing, not stylistic:
 *
 *   - The loader tries a bare `import()` first and only falls back to rewriting the authoring
 *     specifier when that fails — but the fallback uses `Bun.resolveSync`, `Bun.file` and
 *     `Bun.write` (`dist/core/custom.js:73`).
 *   - So a module that imports the authoring specifier loads in the TUI (Bun) and **fails in
 *     `preview.sh` (node)**, and a module that fails to load puts a `⚠` row on the line itself.
 *
 * With no imports the first `import()` succeeds in both runtimes, so what the preview checks is
 * the same file the TUI loads. The file is `.mjs` because node treats a bare `.js` as CommonJS
 * unless the nearest `package.json` sets `"type": "module"`, and this directory has none.
 *
 * The cost: three functions to keep in step if the package changes its definitions. `contextRatio`'s
 * contract — `undefined` when no window was declared, which is what makes the bar disappear rather
 * than lie — is the part that must not drift.
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

function num(config, key, fallback) {
  const value = config[key]
  return typeof value === "number" && Number.isFinite(value) ? value : fallback
}

/**
 * Tick history, shared by `filling` and `rate`. One sample per second, thirty of them — long
 * enough for a slope to mean something, short enough that a slow conversation does not average
 * itself away. `sessionID` is what stops a new session inheriting the last one's slope.
 */
const samples = []
let sessionID

function sample(ctx) {
  if (ctx.session?.id !== sessionID) {
    sessionID = ctx.session?.id
    samples.length = 0
  }
  const last = samples[samples.length - 1]
  if (last && ctx.now - last.at < 1000) return
  samples.push({
    at: ctx.now,
    ratio: contextRatio(ctx.session) ?? 0,
    cost: ctx.session?.cost ?? 0,
  })
  if (samples.length > 30) samples.shift()
}

/** The first and last samples that carry a real reading. */
function span() {
  const seen = samples.filter((entry) => entry.ratio > 0)
  const first = seen[0]
  const last = seen[seen.length - 1]
  if (!first || !last || last.at === first.at) return undefined
  return { first, last }
}

export default {
  segments: {
    /** The context window as a braille gauge. */
    bar(ctx, config) {
      const ratio = contextRatio(ctx.session)
      // Nothing to say beats a confident wrong number: no declared window, no bar.
      if (ratio === undefined) return undefined

      const width = num(config, "width", 10)
      const dots = Math.round(ratio * width * 2)
      const runs = []
      for (let cell = 0; cell < width; cell++) {
        const left = dots > cell * 2
        const right = dots > cell * 2 + 1
        runs.push({
          text: left && right ? "⣿" : left ? "⡇" : "⠀",
          tone: left ? "text" : "border",
        })
      }
      runs.push({ text: ` ${percent(ratio)}`, tone: "text" })
      return { runs }
    },

    /**
     * How fast the window is filling, as a figure rather than a picture.
     *
     * A sparkline would be the obvious richer choice and is deliberately not this: it redraws its
     * whole shape every second, and movement in the corner of your eye pulls attention away from
     * what you are reading. The same information as a rate changes its digits and nothing else.
     */
    filling(ctx) {
      sample(ctx)
      const window = span()
      const ratio = contextRatio(ctx.session)
      if (!window || ratio === undefined) return undefined

      const perMinute = ((window.last.ratio - window.first.ratio) / (window.last.at - window.first.at)) * 60_000 * 100
      if (Math.abs(perMinute) < 0.05) return undefined

      const runs = [{ text: `+${perMinute.toFixed(1)}%/m`, tone: "muted" }]
      if (perMinute > 0) {
        const minutesLeft = ((1 - ratio) * 100) / perMinute
        if (minutesLeft < 90) {
          runs.push({
            text: ` ${Math.round(minutesLeft)}m left`,
            tone: minutesLeft < 15 ? "warning" : "muted",
          })
        }
      }
      return { runs }
    },

    /** Spend per minute, with a direction. Silent where nobody declared prices. */
    rate(ctx) {
      sample(ctx)
      const session = ctx.session
      if (!session?.priced || session.cost <= 0) return undefined
      const window = span()
      if (!window) return undefined

      const perMinute = ((window.last.cost - window.first.cost) / (window.last.at - window.first.at)) * 60_000
      if (perMinute < 0.005) return undefined
      return {
        runs: [
          { text: perMinute > 0.5 ? "▲" : "▸", tone: perMinute > 0.5 ? "warning" : "muted" },
          { text: ` $${perMinute.toFixed(2)}/min`, tone: "muted" },
        ],
      }
    },
  },
}