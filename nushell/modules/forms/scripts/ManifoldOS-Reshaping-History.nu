# =============================================================================
# ManifoldOS — Reshaping History (Temporal Interface)
# =============================================================================

def h [t: string] {
    print $"(ansi red_bold)  ($t)(ansi reset)"
}

def sh [t: string] {
    print $"(ansi grey)  ($t)(ansi reset)"
}

def rh-flow [steps: list, current: string, timings: record] {
    print -n "\e[2J\e[H"
    print ""

    h "MANIFOLD // EXECUTION FLOW"
    sh "state transition across repository surfaces"
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
            print $"  ● ($name) ───► ✓ ($time)"
        } else {
            print $"  ○ ($name)"
        }
    }

    print ""
}

def fetch-commits-from [repo: string, n: int] {
    git -C $repo log --format="%h|%ad|%s|%an" --date=short $"-($n)"
    | lines
    | where { |l| ($l | str trim) != "" }
    | each { |line|
        let p = ($line | split row "|")
        let hash = ($p | get 0)
        let stats = (git -C $repo show --stat $hash | lines | last | str trim)

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
    git -C $repo status --short
    | lines
    | where { |l| ($l | str trim) != "" }
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

def capture-changed [] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let added = (
        git -C $repo diff --cached --name-only --diff-filter=A
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |f| { type: "added" file: $f } }
    )

    let deleted = (
        git -C $repo diff --cached --name-only --diff-filter=D
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |f| { type: "deleted" file: $f } }
    )

    let modified = (
        git -C $repo diff --cached --name-only --diff-filter=M
        | lines
        | where { |l| ($l | str trim) != "" }
        | each { |f| { type: "modified" file: $f } }
    )

    ($added | append $deleted | append $modified)
}

def summarize-impact [changed: list] {
    {
        files: ($changed | length)
        added: ($changed | where type == "added" | length)
        deleted: ($changed | where type == "deleted" | length)
        modified: ($changed | where type == "modified" | length)
    }
}

def render-impact [impact] {
    print ""
    h "IMPACT VECTOR"
    sh "structural mutation induced by this push"
    print ""

    print $"  Files touched : ($impact.files)"
    print $"  Added         : ($impact.added)"
    print $"  Deleted       : ($impact.deleted)"
    print $"  Modified      : ($impact.modified)"
}

def render-position [stats, status] {
    print ""
    h "POSITIONAL STATE"
    sh "alignment relative to remote topology"
    print ""

    print $"  Branch : ($stats.branch)"
    print $"  Sync   : +($stats.ahead) / -($stats.behind)"
    print $"  Total  : ($stats.total)"
    print $"  Push   : ($stats.last_push)"

    if ($status | is-empty) {
        print "  State  : ✓ clean"
    } else {
        print "  State  : dirty"
    }
}

def render-history [commits, changed] {
    print ""
    h "TEMPORAL TRACE"
    sh "recent commit lineage"
    print ""

    let head = ($commits | first)

    if $head != null {
        print $"  ● ($head.hash)  ($head.subject)"
        print $"    ($head.changes)"
        print ""
    }

    h "FILE DELTA (current snapshot)"

    if ($changed | is-empty) {
        print "  — no staged mutations"
    } else {
        for c in $changed {
            if $c.type == "added" {
                print $"  + ($c.file)"
            } else if $c.type == "deleted" {
                print $"  - ($c.file)"
            } else if $c.type == "modified" {
                print $"  ~ ($c.file)"
            }
        }
    }

    print ""

    h "FILE HISTORY (past snapshots)"
    print "  — structural evolution trace —"
    print ""

    let repo = (git rev-parse --show-toplevel | str trim)

    let lines = (
        git -C $repo log --name-status --pretty=format:"%h %ad %s" --date=short -n 6
        | lines
        | where { |l| ($l | str trim) != "" }
    )

    for l in $lines {
        if ($l | str contains "\t") {
            let parts = ($l | split row "\t")
            let tag = ($parts | get 0)
            let file = ($parts | get 1)

            if $tag == "A" {
                print $"  + ($file)"
            } else if $tag == "D" {
                print $"  - ($file)"
            } else if $tag == "M" {
                print $"  ~ ($file)"
            }
        } else {
            print $"  ● ($l)"
        }
    }
}

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let steps = [
        {name: "Fetch"}
        {name: "Stage"}
        {name: "Commit"}
        {name: "Push"}
    ]

    mut timings = {}

    rh-flow $steps "Fetch" $timings
    git -C $repo fetch
    $timings.Fetch = (date now)

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
    render-history $commits $changed
}

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