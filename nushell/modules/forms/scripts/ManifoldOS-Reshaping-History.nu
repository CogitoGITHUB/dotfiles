# =============================================================================
# ManifoldOS Reshaping History
# =============================================================================
# A git log interface built in the ManifoldOS style.
#
# ⚠️  SHARED MODULE WARNING
# =============================================================================
# This script is a shared data provider. The following scripts depend on it:
#
#   - ManifoldOS-Reshaping.nu
#
# Public API:
#   - print-git-sections [repo, changed, push_results]
#   - fetch-commits-from [repo, n]
#   - fetch-status-from [repo]
#   - fetch-repo-stats-from [repo]
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
    if ($rows | is-empty) {
        print $"(ansi grey)  —(ansi reset)"
    } else {
        $rows | print
    }
}


# =============================================================================
# SECTION 3 — DATA COLLECTION (public API)
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
        let parts = ($line | split row "|")
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
    { total: $total  last_push: $last_push  branch: $branch  remote_url: $remote_url  ahead: $ahead  behind: $behind  stash_count: $stash_count }
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
    let added    = (git -C $repo diff --cached --name-only --diff-filter=A | lines | where { |l| $l | is-not-empty } | each { |f| { status: "added"    file: $f  "+": ""  "-": "" } })
    let deleted  = (git -C $repo diff --cached --name-only --diff-filter=D | lines | where { |l| $l | is-not-empty } | each { |f| { status: "deleted"  file: $f  "+": ""  "-": "" } })
    let modified = (git -C $repo diff --cached --numstat --diff-filter=M   | lines | where { |l| $l | is-not-empty } | each { |line|
        let parts = ($line | split row "\t")
        { status: "modified"  file: ($parts | get 2)  "+": ($parts | get 0)  "-": ($parts | get 1) }
    })
    $added | append $deleted | append $modified
}


# =============================================================================
# SECTION 5 — RENDERING (public API)
# =============================================================================

def print-git-sections [repo: string, changed: list, push_results: list] {
    let stats    = (fetch-repo-stats-from $repo)
    let commits  = (fetch-commits-from $repo 10)
    let status   = (fetch-status-from $repo)
    let modified  = ($status | where { |l| not ($l | str starts-with "??") })
    let untracked = ($status | where { |l| $l | str starts-with "??" })

    # --- Push results ---
    if ($push_results | is-not-empty) {
        print-section "PUSH" "steps completed in this operation" (
            $push_results | each { |r| { step: $r.description } }
        )
    }

    # --- Changed files ---
    if ($changed | is-not-empty) {
        print-section "CHANGES" "files modified in this push" $changed
    }

    # --- Commits ---
    print-section "COMMITS" "recent commit history" $commits

    # --- Repo stats ---
    mut stat_rows = [
        { key: "Branch"  value: $stats.branch }
        { key: "Remote"  value: $stats.remote_url }
        { key: "Total"   value: $stats.total }
        { key: "Pushed"  value: $stats.last_push }
    ]
    if $stats.ahead > 0 {
        $stat_rows = ($stat_rows | append { key: "Ahead"  value: $"($stats.ahead) unpushed commit(s)" })
    }
    if $stats.stash_count > 0 {
        $stat_rows = ($stat_rows | append { key: "Stash"  value: $"($stats.stash_count) stashed change(s)" })
    }
    print-section "REPO" "branch and remote state" $stat_rows

    # --- Local status ---
    if ($modified | is-empty) and ($untracked | is-empty) {
        print-section "STATUS" "working tree" [{ state: "✓ clean" }]
    } else {
        let status_rows = (
            ($modified  | each { |l| { kind: "modified"  file: ($l | str trim) } })
            | append ($untracked | each { |l| { kind: "untracked"  file: ($l | str replace "?? " "" | str trim) } })
        )
        print-section "STATUS" "working tree" $status_rows
    }
}

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (try { git rev-parse --show-toplevel | str trim } catch {
        print $"(ansi red_bold)  ✗ Not a git repository(ansi reset)"
        return
    })
    mut results = []

    rh-progress $results "Fetching remote state"
    try { git -C $repo fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    # --- Behind check ---
    let behind_str = (try { git -C $repo rev-list --count HEAD..@{u} | str trim } catch { "0" })
    let behind = (if ($behind_str | is-empty) { 0 } else { $behind_str | into int })
    if $behind > 0 {
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  ⚠ This machine is ($behind) commit(s) behind remote. Pull before pushing.(ansi reset)"
        print ""
        let recent = (git -C $repo log HEAD..@{u} --format="%h  %ad  %an  %s" --date=short | lines)
        for line in $recent { print $"(ansi red)  ($line)(ansi reset)" }
        print ""
        return
    }

    rh-progress $results "Staging all changes"
    stage-all
    $results = ($results | append { description: "All changes staged" })

    let changed = (capture-changed)

    rh-progress $results "Committing"
    let commit_result = (commit-changes $msg | complete)
    if $commit_result.exit_code != 0 {
        $results = ($results | append { description: "Nothing new to commit — already up to date" })
        rh-progress $results "Done"
        print -n "\e[2J\e[H"
        print ""
        print-git-sections $repo [] $results
        print ""
        return
    }
    $results = ($results | append { description: $"Committed: ($msg)" })

    rh-progress $results "Pushing to remote"
    let push_result = (push-changes | complete)
    if $push_result.exit_code != 0 {
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  ✗ Push failed(ansi reset)"
        print ""
        print $push_result.stderr
        print ""
        return
    }
    $results = ($results | append { description: "Pushed to remote" })
    $results = ($results | append { description: "Done" })

    rh-progress $results "Done"
    try { git -C $repo fetch out+err> /dev/null } catch { }

    print -n "\e[2J\e[H"
    print ""
    print-git-sections $repo $changed $results
    print ""
}


# =============================================================================
# SECTION 6 — KEYBINDING
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