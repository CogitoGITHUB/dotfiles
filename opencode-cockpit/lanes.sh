#!/bin/sh
# How many OTHER herdr lanes are working right now.
#
# Prints nothing when the answer is zero — the statusline segment reads an empty
# string as "say nothing", so this pane only shows the figure when there is
# something to say. That keeps a solo session's line short on a 80-column screen.
#
# This window's own agent is in the list while it is working, hence the -1.
herdr agent list 2>/dev/null | python3 -c '
import sys, json
try:
    agents = json.load(sys.stdin)["result"]["agents"]
except Exception:
    sys.exit(0)
busy = [a for a in agents if a.get("agent_status") in ("working", "blocked")]
other = max(0, len(busy) - 1)
if other:
    print("◆%d lanes" % other)
'