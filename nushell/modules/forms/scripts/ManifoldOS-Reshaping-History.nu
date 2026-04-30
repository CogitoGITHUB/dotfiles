# =============================================================================
# ManifoldOS Reshaping History
# =============================================================================

# =============================================================================
# SECTION 1 — PROGRESS
# =============================================================================

def rh-progress [results: list, current: string] {
    print -n "\e[2J\e[H"
    print ""
    print $"(ansi red_bold)  ManifoldOS Reshaping History ...(ansi reset)"
    print ""
    for row in $results {
        print $"(ansi red_bold)  ✓ ($row.description) 🌹(ansi reset)"
    }
    print ""
    print $"  >>> ($current) ❗"
    print ""
}

# =============================================================================
# SECTION 2 — PRINT HELPERS
# =============================================================================

def print-section [label: string, subtitle: string, rows: any] {
    print ""
    print $"(ansi red_bold)  ($label)(ansi reset)"
    print $"(ansi grey)  ($subtitle)(ansi reset)"
    print ""
    if ($rows | is-empty) {
        print $"(ansi grey)  —(ansi reset)"
    } else {
        $env.config.color_config = ($env.config.color_config | upsert header "red_bold")
        print ($rows | table --index false)
    }
}

# =============================================================================
# SECTION 3 — DATA COLLECTION
# =============================================================================

def fetch-commits [n: int] {
    let repo = (git rev-parse --show-toplevel | str trim)
    fetch-commits-from $repo $n
}

def fetch-commits-from [repo: string, n: int] {
    git -C $repo log --format="%h|%ad|%s|%an" --date=short $"-($n)"
    | lines
    | where { |l| $l | is-not-empty }
    | each { |line|
        let parts   = ($line | split row "|")
        let hash    = ($parts | get 0)
        let date    = ($parts | get 1)
        let subject = ($parts | get 2)
        let author  = ($parts | get 3)
        let stats   = (git -C $repo show --stat $hash | lines | last | str trim)
        { hash: $hash  date: $date  author: $author  subject: $subject  changes: $stats }
    }
}

def fetch-status [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    fetch-status-from $repo
}

def fetch-status-from [repo: string] {
    git -C $repo status --short | lines | where { |l| $l | is-not-empty }
}

def fetch-repo-stats [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    fetch-repo-stats-from $repo
}

def fetch-repo-stats-from [repo: string] {
    let total       = (git -C $repo rev-list --count HEAD | str trim)
    let last_push   = (git -C $repo log -1 --format="%ad" --date=relative | str trim)
    let branch      = (git -C $repo branch --show-current | str trim)
    let remote_url  = (try { git -C $repo remote get-url origin | str trim } catch { "none" })
    let ahead       = (try { git -C $repo rev-list --count @{u}..HEAD | str trim | into int } catch { 0 })
    let behind      = (try { git -C $repo rev-list --count HEAD..@{u} | str trim | into int } catch { 0 })
    let stash_count = (try { git -C $repo stash list | lines | length } catch { 0 })
    {
        total:       $total
        last_push:   $last_push
        branch:      $branch
        remote_url:  $remote_url
        ahead:       $ahead
        behind:      $behind
        stash_count: $stash_count
    }
}

# =============================================================================
# SECTION 4 — WRITE OPERATIONS
# =============================================================================

def stage-all [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    git -C $repo add --all
}

def commit-changes [msg: string] {
    let repo = (git rev-parse --show-toplevel | str trim)
    git -C $repo commit -m $msg
}

def push-changes [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    git -C $repo push
}

def capture-changed [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    let added = (
        git -C $repo diff --cached --name-only --diff-filter=A
        | lines
        | where { |l| $l | is-not-empty }
        | each { |f| { status: "added"  file: $f  "+": ""  "-": "" } }
    )
    let deleted = (
        git -C $repo diff --cached --name-only --diff-filter=D
        | lines
        | where { |l| $l | is-not-empty }
        | each { |f| { status: "deleted"  file: $f  "+": ""  "-": "" } }
    )
    let modified = (
        git -C $repo diff --cached --numstat --diff-filter=M
        | lines
        | where { |l| $l | is-not-empty }
        | each { |line|
            let parts = ($line | split row "\t")
            { status: "modified"  file: ($parts | get 2)  "+": ($parts | get 0)  "-": ($parts | get 1) }
        }
    )
    $added | append $deleted | append $modified
}

# =============================================================================
# SECTION 5 — RENDERING
# =============================================================================

def print-git-sections [repo: string, changed: list, push_results: list] {
    let stats     = (fetch-repo-stats-from $repo)
    let commits   = (fetch-commits-from $repo 10)
    let status    = (fetch-status-from $repo)
    let modified  = ($status | where { |l| not ($l | str starts-with "??") })
    let untracked = ($status | where { |l| $l | str starts-with "??" })

    if ($push_results | is-not-empty) {
        print-section "PUSH" "steps completed in this operation" (
            $push_results | each { |r| {
                "Step": $"(ansi red_bold)($r.description)(ansi reset)"
                "":     "🌹"
            }}
        )
    }

    if ($changed | is-not-empty) {
        print-section "CHANGES" "files modified in this push" (
            $changed | each { |r| {
                "Status": $"(ansi red_bold)($r.status)(ansi reset)"
                "File":   $"(ansi red)($r.file)(ansi reset)"
                "+":      $"(ansi red)($r."+")(ansi reset)"
                "-":      $"(ansi red)($r."-")(ansi reset)"
            }}
        )
    }

    print-section "COMMITS" "recent commit history" (
        $commits | each { |r| {
            "Hash":    $"(ansi red_bold)($r.hash)(ansi reset)"
            "Date":    $"(ansi red)($r.date)(ansi reset)"
            "Author":  $"(ansi red)($r.author)(ansi reset)"
            "Changes": $"(ansi red)($r.changes)(ansi reset)"
        }}
    )

    mut stat_rows = [
        { "": $"(ansi red_bold)Branch(ansi reset)"  " ": $"(ansi red)($stats.branch)(ansi reset)" }
        { "": $"(ansi red_bold)Remote(ansi reset)"  " ": $"(ansi red)($stats.remote_url)(ansi reset)" }
        { "": $"(ansi red_bold)Total(ansi reset)"   " ": $"(ansi red)($stats.total)(ansi reset)" }
        { "": $"(ansi red_bold)Pushed(ansi reset)"  " ": $"(ansi red)($stats.last_push)(ansi reset)" }
    ]

    print-section "REPO" "branch and remote state" $stat_rows

    if ($modified | is-empty) and ($untracked | is-empty) {
        print-section "STATUS" "working tree" [
            { "State": $"(ansi red_bold)✓ clean(ansi reset)" }
        ]
    } else {
        print-section "STATUS" "working tree" (
            ($modified | each { |l| {
                "Kind": $"(ansi red_bold)modified(ansi reset)"
                "File": $"(ansi red)($l | str trim)(ansi reset)"
            }})
            | append ($untracked | each { |l| {
                "Kind": $"(ansi red_bold)untracked(ansi reset)"
                "File": $"(ansi red)($l | str replace '?? ' '' | str trim)(ansi reset)"
            }})
        )
    }
}

# =============================================================================
# SECTION 6 — MAIN
# =============================================================================

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (try { git rev-parse --show-toplevel | str trim } catch {
        print $"(ansi red_bold)  ✗ Not a git repository(ansi reset)"
        return
    })

    mut results = []

    rh-progress $results "Fetching remote state"
    try { git -C $repo fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    let behind_str = (try { git -C $repo rev-list --count HEAD..@{u} | str trim } catch { "0" })
    let behind = (if ($behind_str | is-empty) { 0 } else { $behind_str | into int })

    if $behind > 0 {
        print $"(ansi red_bold)  ⚠ Behind remote.(ansi reset)"
        return
    }

    rh-progress $results "Staging all changes"
    stage-all
    $results = ($results | append { description: "All changes staged" })
    let changed = (capture-changed)

    rh-progress $results "Committing"
    let commit_result = (commit-changes $msg | complete)

    if $commit_result.exit_code != 0 {
        $results = ($results | append { description: "Nothing to commit" })
        print-git-sections $repo [] $results
        return
    }

    $results = ($results | append { description: $"Committed: ($msg)" })

    rh-progress $results "Pushing"
    let push_result = (push-changes | complete)

    if $push_result.exit_code != 0 {
        print $"(ansi red_bold)Push failed(ansi reset)"
        return
    }

    $results = ($results | append { description: "Pushed" })

    print-git-sections $repo $changed $results
}

# =============================================================================
# SECTION 7 — KEYBINDING
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