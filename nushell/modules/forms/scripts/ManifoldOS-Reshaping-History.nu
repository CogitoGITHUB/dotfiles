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
        let idx = $row.index
        let time = ($timings | get -i $name | default "")

        if $current == "" {
            print $"  ○ ($name) ───── ($time)"
        } else if $idx < $current_index {
            print $"  🌹 ($name) ───── ✓ ($time)"
        } else if $idx == $current_index {
            print $"  ● ($name) ───► ($time)"
        } else {
            print $"  ○ ($name) ───── pending"
        }
    }

    print ""
}

# =============================================================================
# DATA
# =============================================================================

def fetch-commits-from [repo: string, n: int] {
    git -C $repo log --format="%h|%ad|%s|%an" --date=short $"-($n)"
    | lines
    | where { |l| ($l | str trim) != "" }
    | each { |line|
        let p = ($line | split row "|")
        let hash = ($p | get 0)
        let stats = (git -C $repo show --stat $hash | lines | last | default "")

        {
            hash: $hash
            date: ($p | get 1)
            subject: ($p | get 2)
            author: ($p | get 3)
            changes: $stats
        }
    }
}

def fetch-status-from [repo: string] {
    git -C $repo status --short | lines | where { |l| ($l | str trim) != "" }
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
# CHANGES
# =============================================================================

def capture-changed [] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let added = (
        git -C $repo diff --cached --name-only --diff-filter=A
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |f| { type: "added", file: $f } }
    )

    let deleted = (
        git -C $repo diff --cached --name-only --diff-filter=D
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |f| { type: "deleted", file: $f } }
    )

    let modified = (
        git -C $repo diff --cached --numstat --diff-filter=M
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |line|
            let p = ($line | split row "\t")
            {
                type: "modified"
                file: ($p | get 2)
                plus: ($p | get 0)
                minus: ($p | get 1)
            }
        }
    )

    ($added | append $deleted | append $modified)
}

# =============================================================================
# IMPACT
# =============================================================================

def summarize-impact [changed: list] {
    let files = ($changed | length)
    let added = ($changed | where type == "added" | length)
    let deleted = ($changed | where type == "deleted" | length)
    let modified = ($changed | where type == "modified" | length)

    let plus = (
        $changed | where type == "modified" | get -i plus
        | each { |x| if $x == "" { 0 } else { $x | into int } }
        | math sum
    )

    let minus = (
        $changed | where type == "modified" | get -i minus
        | each { |x| if $x == "" { 0 } else { $x | into int } }
        | math sum
    )

    {
        files: $files
        added: $added
        deleted: $deleted
        modified: $modified
        plus: $plus
        minus: $minus
        net: ($plus - $minus)
    }
}

def render-impact [impact] {
    print ""
    print $"(ansi red_bold)🌹 IMPACT VECTOR 🌹(ansi reset)"
    print $"(ansi grey)Structural mutation signature of this commit.(ansi reset)"
    print ""

    print $"  Files touched : ($impact.files)"
    print $"  Added         : ($impact.added)"
    print $"  Deleted       : ($impact.deleted)"
    print $"  Modified      : ($impact.modified)"
    print $"  Composition   : +($impact.plus) / -($impact.minus) net=($impact.net)"
}

# =============================================================================
# POSITION
# =============================================================================

def render-position [stats, status] {
    print ""
    print $"(ansi red_bold)🌹 POSITIONAL STATE 🌹(ansi reset)"
    print $"(ansi grey)Alignment between local drift and upstream truth.(ansi reset)"
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

# =============================================================================
# HISTORY
# =============================================================================

def render-history [commits] {
    print ""
    print $"(ansi red_bold)🌹 TEMPORAL TRACE 🌹(ansi reset)"
    print $"(ansi grey)Compressed lineage of repository evolution.(ansi reset)"
    print ""

    if ($commits | is-empty) {
        print "  (no history)"
        return
    }

    let head = ($commits | first)

    print $"  ● ($head.hash)  ($head.subject)"
    print $"    ($head.changes)"
    print ""

    print $"  Past:"
    for c in ($commits | skip 1 | take 6) {
        print $"  ○ ($c.hash)  ($c.subject)"
    }
}

# =============================================================================
# MAIN
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

    print ""
    print ""
}

# =============================================================================
# KEYBINDING
# =============================================================================

$env.config.keybindings = ($env.config.keybindings | append {
    name: ManifoldOS_Reshaping_History
    modifier: control
    keycode: char_g
    mode: emacs
    event: {
        send: executehostcommand
        cmd: "ManifoldOS-Reshaping-History"
    }
})