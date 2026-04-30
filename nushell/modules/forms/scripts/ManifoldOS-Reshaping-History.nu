# =============================================================================
# ManifoldOS — Reshaping History (Temporal Interface)
# =============================================================================


# =============================================================================
# SECTION 1 — FLOW ENGINE
# =============================================================================

def rh-flow [steps: list, current: string, timings: record] {
    print -n "\e[2J\e[H"
    print ""

    print $"(ansi red_bold)🌹 MANIFOLD // EXECUTION FLOW 🌹(ansi reset)"
    print $"(ansi grey)A staged collapse of repository time: actions exist as pressure before stabilizing into recorded history.(ansi reset)"
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
        let time = ($timings | get -i $name | default "")
        let is_done = ($timings | get -i $name | is-not-empty)
        let is_active = ($name == $current)

        let symbol = if $is_done and not $is_active { "🌹" } else { "○" }
        let status = if $is_active { "───►" } else if $is_done { "✓" } else { "─────" }

        print $"  ($symbol) ($name) ($status) ($time)"
    }

    print ""
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
    git -C $repo status --short
    | lines
    | where { |l| $l | is-not-empty }
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
# SECTION 3 — IMPACT
# =============================================================================

def capture-changed [] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let added = (
        git -C $repo diff --cached --name-only --diff-filter=A
        | lines
        | where { |l| $l | is-not-empty }
        | each { |f| { status: "added" file: $f } }
    )

    let deleted = (
        git -C $repo diff --cached --name-only --diff-filter=D
        | lines
        | where { |l| $l | is-not-empty }
        | each { |f| { status: "deleted" file: $f } }
    )

    let modified = (
        git -C $repo diff --cached --name-only --diff-filter=M
        | lines
        | where { |l| $l | is-not-empty }
        | each { |f| { status: "modified" file: $f } }
    )

    $added | append $deleted | append $modified
}

def summarize-impact [changed: list] {
    {
        files: ($changed | length)
        added: ($changed | where status == "added" | length)
        deleted: ($changed | where status == "deleted" | length)
        modified: ($changed | where status == "modified" | length)
    }
}


# =============================================================================
# SECTION 4 — RENDERING
# =============================================================================

def render-impact [impact] {
    print ""
    print $"(ansi red_bold)🌹 IMPACT VECTOR 🌹(ansi reset)"
    print $"(ansi grey)Structural mutation signature of this commit.(ansi reset)"
    print ""

    print $"  Files touched : ($impact.files)"
    print $"  Added         : ($impact.added)"
    print $"  Deleted       : ($impact.deleted)"
    print $"  Modified      : ($impact.modified)"

    print ""
    print ""
}

def render-position [stats, status] {
    print $"(ansi red_bold)🌹 POSITIONAL STATE 🌹(ansi reset)"
    print $"(ansi grey)Alignment between local drift and upstream state.(ansi reset)"
    print ""

    print $"  Branch : ($stats.branch)"
    print $"  Sync   : +($stats.ahead) / -($stats.behind)"
    print $"  Total  : ($stats.total)"
    print $"  Push   : ($stats.last_push)"

    print $"  State  : (if ($status | is-empty) { '✓ clean' } else { 'dirty' })"

    print ""
    print ""
}

def render-history [commits] {
    print $"(ansi red_bold)🌹 TEMPORAL TRACE 🌹(ansi reset)"
    print $"(ansi grey)Compressed lineage of repository evolution.(ansi reset)"
    print ""

    let head = ($commits | first)

    print $"  ● ($head.hash)  ($head.subject)"
    print $"    ($head.changes)"
    print ""

    print "  Past:"
    for c in ($commits | skip 1 | take 8) {
        print $"  ○ ($c.hash)  ($c.subject)"
    }

    print ""
    print ""
}

def render-file-delta [changed] {
    print $"(ansi red_bold)🌹 FILE DELTA 🌹(ansi reset)"
    print $"(ansi grey)What has just been altered in the system state.(ansi reset)"
    print ""

    if ($changed | is-empty) {
        print "  (no changes)"
    } else {
        for c in $changed {
            if $c.status == "added" {
                print $"  + ($c.file)"
            } else if $c.status == "deleted" {
                print $"  - ($c.file)"
            } else {
                print $"  ~ ($c.file)"
            }
        }
    }

    print ""
    print ""
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
    git -C $repo fetch out+err> /dev/null
    $timings.Fetch = ((date now) - $start)

    $start = (date now)
    rh-flow $steps "Stage" $timings
    git -C $repo add --all
    $timings.Stage = ((date now) - $start)

    let changed = (capture-changed)

    $start = (date now)
    rh-flow $steps "Commit" $timings
    let c = (git -C $repo commit -m $msg | complete)
    $timings.Commit = ((date now) - $start)

    if $c.exit_code != 0 { return }

    $start = (date now)
    rh-flow $steps "Push" $timings
    git -C $repo push
    $timings.Push = ((date now) - $start)

    print -n "\e[2J\e[H"

    let stats = (fetch-repo-stats-from $repo)
    let status = (fetch-status-from $repo)
    let commits = (fetch-commits-from $repo 10)
    let impact = (summarize-impact $changed)

    rh-flow $steps "" $timings

    render-impact $impact
    render-position $stats $status
    render-history $commits
    render-file-delta $changed
}


# =============================================================================
# KEYBINDING
# =============================================================================

$env.config.keybindings = (
    $env.config.keybindings
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