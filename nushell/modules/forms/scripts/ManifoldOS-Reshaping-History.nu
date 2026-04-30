# =============================================================================
# ManifoldOS Reshaping History
# =============================================================================
# A git log interface built in the ManifoldOS style.
# Shows recent commit history, repo stats, and current local status
# in a single unified red table.
#
# ⚠️  SHARED MODULE WARNING
# =============================================================================
# This script is a shared data provider. The following scripts depend on it:
#
#   - ManifoldOS-Reshaping.nu  (uses reshaping-history-rows to build its
#                               unified summary table)
#
# The following functions are part of the public API and must not be renamed,
# removed, or have their return shape changed without updating all consumers:
#
#   - reshaping-history-rows [n: int = 10, left: string, right: string]
#       Returns a list of records with columns (left) and (right)
#
#   - fetch-commits [n: int]
#       Returns a list of records with fields: hash, date, subject, stats
#
#   - fetch-status []
#       Returns a list of strings (git status --short lines)
#
#   - fetch-repo-stats []
#       Returns a record with fields: total, last_push, branch, remote_url,
#       ahead, behind, stash_count
#
# Safe to change freely:
#   - ManifoldOS-Reshaping-History (the main entry point)
#   - rh-progress (internal progress renderer)
#   - Visual styling inside reshaping-history-rows
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
# SECTION 2 — DATA COLLECTION (public API — see warning above)
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
        let hash = ($parts | get 0)
        let date = ($parts | get 1)
        let subject = ($parts | get 2)
        let author = ($parts | get 3)
        let stats = (
            git -C $repo show --stat $hash
            | lines
            | last
            | str trim
        )
        {
            hash: $hash
            date: $date
            subject: $subject
            author: $author
            stats: $stats
        }
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
    let total = (git -C $repo rev-list --count HEAD | str trim)
    let last_push = (git -C $repo log -1 --format="%ad" --date=relative | str trim)
    let branch = (git -C $repo branch --show-current | str trim)
    let remote_url = (try { git -C $repo remote get-url origin | str trim } catch { "none" })
    let ahead = (try { git -C $repo rev-list --count @{u}..HEAD | str trim | into int } catch { 0 })
    let behind = (try { git -C $repo rev-list --count HEAD..@{u} | str trim | into int } catch { 0 })
    let stash_count = (try { git -C $repo stash list | lines | length } catch { 0 })
    {
        total: $total
        last_push: $last_push
        branch: $branch
        remote_url: $remote_url
        ahead: $ahead
        behind: $behind
        stash_count: $stash_count
    }
}


# =============================================================================
# SECTION 3 — WRITE OPERATIONS
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

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (try { git rev-parse --show-toplevel | str trim } catch {
        print $"(ansi red_bold)  ✗ Not a git repository(ansi reset)"
        return
    })
    mut results = []

    # --- Fetch remote first ---
    rh-progress $results "Fetching remote state"
    try { git -C $repo fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    # --- Check if we are behind remote ---
    let behind_str = (try { git -C $repo rev-list --count HEAD..@{u} | str trim } catch { "0" })
    let behind = (if ($behind_str | is-empty) { 0 } else { $behind_str | into int })
    if $behind > 0 {
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  ⚠ This machine is ($behind) commit(s) behind remote. Pull before pushing.(ansi reset)"
        print ""
        let recent = (git -C $repo log HEAD..@{u} --format="%h  %ad  %an  %s" --date=short | lines)
        for line in $recent {
            print $"(ansi red)  ($line)(ansi reset)"
        }
        print ""
        return
    }

    # --- Stage ---
    rh-progress $results "Staging all changes"
    stage-all
    $results = ($results | append { description: "All changes staged" })

    # --- Capture what changed BEFORE committing ---
    let added_files = (git -C $repo diff --cached --name-only --diff-filter=A | lines | where { |l| $l | is-not-empty })
    let deleted_files = (git -C $repo diff --cached --name-only --diff-filter=D | lines | where { |l| $l | is-not-empty })
    let modified_files = (git -C $repo diff --cached --numstat --diff-filter=M | lines | where { |l| $l | is-not-empty } | each { |line|
        let parts = ($line | split row "\t")
        {
            "File": ($parts | get 2)
            "+": ($parts | get 0)
            "-": ($parts | get 1)
        }
    })

    # --- Commit ---
    rh-progress $results "Committing"
    let commit_result = (commit-changes $msg | complete)
    if $commit_result.exit_code != 0 {
        $results = ($results | append { description: "Nothing new to commit — already up to date" })
        rh-progress $results "Done"
        print ""
        print (reshaping-history-rows 5 | table --index false)
        print ""
        return
    }
    $results = ($results | append { description: $"Committed: ($msg)" })

    # --- Push ---
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

    # --- Changes table ---
    let has_changes = (($added_files | is-not-empty) or ($deleted_files | is-not-empty) or ($modified_files | is-not-empty))
    if $has_changes {
        mut change_rows = []
        for f in $added_files {
            $change_rows = ($change_rows | append { "Status": $"(ansi green)added(ansi reset)"    "File": $"(ansi green)($f)(ansi reset)"   "+": "" "-": "" })
        }
        for f in $deleted_files {
            $change_rows = ($change_rows | append { "Status": $"(ansi red)deleted(ansi reset)"  "File": $"(ansi red)($f)(ansi reset)"     "+": "" "-": "" })
        }
        for row in $modified_files {
            $change_rows = ($change_rows | append { "Status": $"(ansi yellow)modified(ansi reset)" "File": $"(ansi yellow)($row.File)(ansi reset)" "+": $"(ansi green)+($row."+")(ansi reset)" "-": $"(ansi red)-($row."-")(ansi reset)" })
        }
        print ""
        print ($change_rows | table --index false)
    }

    print ""
    print (reshaping-history-rows 5 | table --index false)
    print ""
}


# =============================================================================
# SECTION 4 — RENDERING (public API — see warning above)
# =============================================================================

def reshaping-history-rows [n: int = 10, left: string = "Reshaping History", right: string = "Details", repo: string = ""] {
    let repo = if ($repo | is-empty) {
        try { git rev-parse --show-toplevel | str trim } catch { "." }
    } else {
        $repo
    }
    let commits = (fetch-commits-from $repo $n)
    let stats = (fetch-repo-stats-from $repo)
    let status = (fetch-status-from $repo)

    # separate untracked from modified
    let modified = ($status | where { |l| not ($l | str starts-with "??") })
    let untracked = ($status | where { |l| $l | str starts-with "??" })

    mut rows = []

    for commit in $commits {
        $rows = ($rows | append {
            ($left): $"(ansi red_bold)($commit.hash)  ($commit.date)  ($commit.author)(ansi reset)"
            ($right): $"(ansi red)($commit.subject)  ($commit.stats)(ansi reset)"
        })
    }

    $rows = ($rows | append {
        ($left): $"(ansi red_bold)─────────────────────────────(ansi reset)"
        ($right): $"(ansi red_bold)─────────────────────────────────────────────────────(ansi reset)"
    })

    $rows = ($rows | append { ($left): $"(ansi red_bold)Branch(ansi reset)"        ($right): $"(ansi red)($stats.branch)(ansi reset)" })
    $rows = ($rows | append { ($left): $"(ansi red_bold)Remote(ansi reset)"        ($right): $"(ansi red)($stats.remote_url)(ansi reset)" })
    $rows = ($rows | append { ($left): $"(ansi red_bold)Total Commits(ansi reset)" ($right): $"(ansi red)($stats.total)(ansi reset)" })
    $rows = ($rows | append { ($left): $"(ansi red_bold)Last Push(ansi reset)"     ($right): $"(ansi red)($stats.last_push)(ansi reset)" })

    if $stats.ahead > 0 {
        $rows = ($rows | append { ($left): $"(ansi red_bold)Ahead(ansi reset)" ($right): $"(ansi yellow)($stats.ahead) unpushed commit(s)(ansi reset)" })
    }

    if $stats.stash_count > 0 {
        $rows = ($rows | append { ($left): $"(ansi red_bold)Stash(ansi reset)" ($right): $"(ansi yellow)($stats.stash_count) stashed change(s)(ansi reset)" })
    }

    $rows = ($rows | append {
        ($left): $"(ansi red_bold)─────────────────────────────(ansi reset)"
        ($right): $"(ansi red_bold)─────────────────────────────────────────────────────(ansi reset)"
    })

    if ($modified | is-empty) and ($untracked | is-empty) {
        $rows = ($rows | append {
            ($left): $"(ansi red_bold)Local Status(ansi reset)"
            ($right): $"(ansi red)✓ clean(ansi reset)"
        })
    } else {
        for line in $modified {
            $rows = ($rows | append {
                ($left): $"(ansi red_bold)Modified(ansi reset)"
                ($right): $"(ansi red)($line | str trim)(ansi reset)"
            })
        }
        for line in $untracked {
            $rows = ($rows | append {
                ($left): $"(ansi red_bold)Untracked(ansi reset)"
                ($right): $"(ansi yellow)($line | str trim | str replace '?? ' '')(ansi reset)"
            })
        }
    }

    $rows
}

def ManifoldOS-Reshaping-History-Display [n: int = 10] {
    mut results = []

    rh-progress $results "Fetching remote state"
    try {
        let repo = (git rev-parse --show-toplevel | str trim)
        git -C $repo fetch out+err> /dev/null
    } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    rh-progress $results "Building history"
    $results = ($results | append { description: "History built" })

    print -n "\e[2J\e[H"
    print ""
    print (reshaping-history-rows $n | table --index false)
    print ""
}


# =============================================================================
# SECTION 5 — KEYBINDING
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