# =============================================================================
# ManifoldOS — Reshaping History (Temporal Interface)
# =============================================================================

# =============================================================================
# SECTION 1 — FLOW ENGINE
# =============================================================================

def rh-flow [steps: list, current: string, timings: record] {
    print -n "\e[2J\e[H"
    print ""
    print $"(ansi red_bold)  MANIFOLD // EXECUTION FLOW(ansi reset)"
    print $"(ansi grey)  state transition across repository surfaces(ansi reset)"
    print ""

    let indexed = ($steps | enumerate)

    mut current_index = -1
    for row in $indexed {
        if $row.item.name == $current {
            $current_index = $row.index
        }
    }

    for row in $indexed {
        let name = $row.item.name
        let idx  = $row.index
        let time = ($timings | get -i $name | default "")

        if $current_index == -1 {
            print $"  ● ($name) ───── ✓ ($time)"
        } else if $idx < $current_index {
            print $"  ● ($name) ───── ✓ ($time)"
        } else if $idx == $current_index {
            print $"  ● ($name) ───► ($time)"
        } else {
            print $"  ○ ($name)"
        }
    }

    print ""
}

# =============================================================================
# SECTION 2 — DATA
# =============================================================================

def fetch-commits-from [repo: string, n: int] {
    git -C $repo log --format="%h|%ad|%s|%an" --date=short $"-($n)"
    | lines
    | where { |l| $l | is-not-empty }
    | each { |line|
        let p = ($line | split row "|")
        let stats = (git -C $repo show --stat ($p | get 0) | lines | last | str trim)
        {
            hash: ($p | get 0)
            date: ($p | get 1)
            subject: ($p | get 2)
            author: ($p | get 3)
            changes: $stats
        }
    }
}

def fetch-status-from [repo: string] {
    git -C $repo status --short | lines | where { |l| $l | is-not-empty }
}

def fetch-repo-stats-from [repo: string] {
    {
        branch: (git -C $repo branch --show-current | str trim)
        total: (git -C $repo rev-list --count HEAD | str trim)
        last_push: (git -C $repo log -1 --format="%ad" --date=relative | str trim)
        ahead: (try { git -C $repo rev-list --count @{u}..HEAD | into int } catch { 0 })
        behind: (try { git -C $repo rev-list --count HEAD..@{u} | into int } catch { 0 })
    }
}

# =============================================================================
# SECTION 3 — IMPACT ANALYSIS
# =============================================================================

def summarize-impact [changed: list] {
    let added = ($changed | where status == "added" | length)
    let deleted = ($changed | where status == "deleted" | length)
    let modified = ($changed | where status == "modified")

    let plus = ($modified | get "+" | math sum)
    let minus = ($modified | get "-" | math sum)

    {
        files: ($changed | length)
        added: $added
        deleted: $deleted
        modified: ($modified | length)
        plus: $plus
        minus: $minus
        net: ($plus - $minus)
    }
}

# =============================================================================
# SECTION 3.5 — CHANGE CAPTURE
# =============================================================================

def capture-changed [] {
    let repo = (git rev-parse --show-toplevel | str trim)

    git -C $repo diff --cached --name-only
    | lines
    | where { |l| $l | is-not-empty }
    | each { |f| { status: "modified" file: $f "+" : 0 "-" : 0 } }
}

# =============================================================================
# SECTION 4 — RENDERING
# =============================================================================

def render-impact [impact] {
    print ""
    print $"(ansi red_bold)  IMPACT VECTOR(ansi reset)"
    print $"(ansi grey)  structural mutation induced by this push(ansi reset)"
    print ""

    print $"  Files touched : ($impact.files)"
    print $"  Composition   : +($impact.plus) / -($impact.minus)  net=($impact.net)"

    if $impact.files > 20 {
        print $"(ansi red)  ⚠ wide spread change surface(ansi reset)"
    }

    if $impact.minus > 1000 {
        print $"(ansi red)  ⚠ large deletion anomaly(ansi reset)"
    }
}

def render-position [stats, status] {
    print ""
    print $"(ansi red_bold)  POSITIONAL STATE(ansi reset)"
    print $"(ansi grey)  current alignment in relation to remote(ansi reset)"
    print ""

    print $"  Branch : ($stats.branch)"
    print $"  Sync   : +($stats.ahead) / -($stats.behind)"
    print $"  Total  : ($stats.total)"
    print $"  Push   : ($stats.last_push)"

    if ($status | is-empty) {
        print $"  State  : ✓ clean"
    } else {
        print $"  State  : dirty"
    }
}

def render-history [commits] {
    print ""
    print $"(ansi red_bold)  TEMPORAL TRACE(ansi reset)"
    print $"(ansi grey)  recent state transitions (weighted scan)(ansi reset)"
    print ""

    let head = ($commits | first)

    if $head != null {
        print $"  ● ($head.hash)  ($head.subject)"
        print $"    ($head.changes)"
        print ""
    }

    print $"  Past:"
    for c in ($commits | skip 1 | take 6) {
        print $"  ○ ($c.hash)  ($c.subject)"
    }
}

# =============================================================================
# SECTION 5 — MAIN
# =============================================================================

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let steps = [
        {name: "Fetch"}
        {name: "Stage"}
        {name: "Commit"}
        {name: "Push"}
    ]

    mut timings = {}
    mut start = (date now)

    rh-flow $steps "Fetch" $timings
    git -C $repo fetch
    $timings.Fetch = (date now)

    $start = (date now)
    rh-flow $steps "Stage" $timings
    git -C $repo add --all
    $timings.Stage = (date now)

    let changed = (capture-changed)

    rh-flow $steps "Commit" $timings
    let c = (git -C $repo commit -m $msg | complete)
    $timings.Commit = (date now)

    if $c.exit_code != 0 {
        print "Nothing to commit"
        return
    }

    rh-flow $steps "Push" $timings
    git -C $repo push
    $timings.Push = (date now)

    print -n "\e[2J\e[H"

    let stats = (fetch-repo-stats-from $repo)
    let status = (fetch-status-from $repo)
    let commits = (fetch-commits-from $repo 10)
    let impact = (summarize-impact $changed)

    rh-flow $steps "" $timings
    render-impact $impact
    render-position $stats $status
    render-history $commits
}

# =============================================================================
# KEYBINDING
# =============================================================================

$env.config.keybindings = (
    $env.config.keybindings
    | where name != "ManifoldOS_Reshaping_History"
    | append {
        name: ManifoldOS_Reshaping_History
        modifier: control
        keycode: char_g
        mode: emacs
        event: {
            send: executehostcommand
            cmd: "ManifoldOS-Reshaping-History"
        }
    }
)