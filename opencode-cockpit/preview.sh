#!/bin/sh
# Render the statusline config without restarting OpenCode.
#
# Why this exists: the plugin reads config.json exactly once, at plugin load.
# `dist/tui/index.js:40` calls loadStatusConfig during setup, then line 74
# freezes the result with resolveLines — the per-frame memo rebuilds the line
# from the session snapshot, never from the config. So editing config.json and
# waiting does nothing; the only way to see a change in the TUI is a restart,
# which on a phone is an expensive way to find out whether a priority number is
# right.
#
# This runs the package's own preview CLI against the same config file, in about
# a second, against the exact copy of the plugin OpenCode has installed.
#
#   sh preview.sh                  # all six states at this box's 80 columns
#   sh preview.sh --debug          # mark segments that drew nothing
#   sh preview.sh --state fresh    # one state: fresh|working|full|unpriced|retrying|empty
#   sh preview.sh --watch          # redraw on every save
#   WIDTH=120 sh preview.sh        # a different width
#
# The package declares `engines.bun >= 1.3.5` and its CLI uses Bun APIs, but it
# runs fine under plain node — which is what this box has.
set -e

WIDTH=${WIDTH:-80}

# OpenCode caches each plugin at .../status@latest/<timestamp>/node_modules/<pkg>.
# Point at that copy so the preview always matches what the TUI is running,
# rather than whatever npm happens to have in a scratch directory.
CACHE=$(ls -d "$HOME"/.cache/opencode/npm/@opencode-cockpit/status@latest/*/node_modules/@opencode-cockpit/status 2>/dev/null | tail -n 1)

if [ -z "$CACHE" ]; then
  echo "status plugin not found in OpenCode's cache." >&2
  echo "Start OpenCode once so it installs, or set CACHE=<path to the package>." >&2
  exit 1
fi

cd "$CACHE"
exec node ./dist/cli/preview.js --width "$WIDTH" "$@"