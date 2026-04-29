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
#   - reshaping-history-rows [n: int = 10]
#       Returns a list of records with columns "Reshaping History" and "Details"
#
#   - fetch-commits [n: int]
#       Returns a list of records with fields: hash, date, stats
#
#   - fetch-status []
#       Returns a list of strings (git status --short lines)
#
#   - fetch-repo-stats []
#       Returns a record with fields: total, last_push, branch
#
# Safe to change freely:
#   - reshaping-history (the display command, only used by the keybinding)
#   - reshaping-push (the add/commit/push command)
#   - rh-progress (internal progress renderer)
#   - Visual styling inside reshaping-history-rows (colors, dividers, labels)
#     as long as the column names stay the same
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
    git -C $repo log --format="%h|%ad|%s" --date=short $"-($n)"
    | lines
    | where { |l| $l | is-not-empty }
    | each { |line|
        let parts = ($line | split row "|")
        let hash = ($parts | get 0)
        let date = ($parts | get 1)
        let stats = (
            git -C $repo show --stat $hash
            | lines
            | last
            | str trim
        )
        let subject = (git -C $repo log -1 --format="%s" $hash | str trim)
        {
            hash: $hash
            date: $date
            stats: $stats
            subject: $subject
        }
    }
}

def fetch-status [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    git -C $repo status --short | lines | where { |l| $l | is-not-empty }
}

def fetch-repo-stats [] {
    let repo = (git rev-parse --show-toplevel | str trim)
    let total = (git -C $repo rev-list --count HEAD | str trim)
    let last_push = (git -C $repo log -1 --format="%ad" --date=relative | str trim)
    let branch = (git -C $repo branch --show-current | str trim)
    {
        total: $total
        last_push: $last_push
        branch: $branch
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
    let repo = (git rev-parse --show-toplevel | str trim)
    mut results = []

    # --- Fetch remote first ---
    rh-progress $results "Fetching remote state"
    try { git -C $repo fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    # --- Check if we are behind remote ---
    let behind = (git -C $repo rev-list --count HEAD..@{u} | str trim | into int)
    if $behind > 0 {
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  ⚠ This machine is ($behind) commit(s) behind remote. Pull before pushing.(ansi reset)"
        print ""
        let recent = (git -C $repo log HEAD..@{u} --format="%h  %ad  %s" --date=short | lines)
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

    # --- Capture what changed after staging ---
    let changed = (git -C $repo diff --cached --stat | lines | where { |l| $l | is-not-empty })

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

    # --- Changes ---
    print ""
    if ($changed | is-not-empty) {
        let change_rows = (git -C $repo diff --cached --numstat | lines | where { |l| $l | is-not-empty } | each { |line|
            let parts = ($line | split row "\t")
            {
                "File": ($parts | get 2)
                "+": ($parts | get 0)
                "-": ($parts | get 1)
            }
        })
        print ($change_rows | table --index false)
        print ""
    }

    print (reshaping-history-rows 5 | table --index false)
    print ""
}


# =============================================================================
# SECTION 4 — RENDERING (public API — see warning above)
# =============================================================================

def reshaping-history-rows [n: int = 10] {
    let commits = (fetch-commits $n)
    let stats = (fetch-repo-stats)
    let status = (fetch-status)

    mut rows = []

    for commit in $commits {
        $rows = ($rows | append {
            "Reshaping History": $"(ansi red_bold)($commit.hash)  ($commit.date)(ansi reset)"
            "Details": $"(ansi red)($commit.subject)  ($commit.stats)(ansi reset)"
        })
    }

    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "Details": ""
    })

    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Branch(ansi reset)"        "Details": $"(ansi red)($stats.branch)(ansi reset)" })
    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Total Commits(ansi reset)" "Details": $"(ansi red)($stats.total)(ansi reset)" })
    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Last Push(ansi reset)"     "Details": $"(ansi red)($stats.last_push)(ansi reset)" })

    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "Details": ""
    })

    if ($status | is-empty) {
        $rows = ($rows | append {
            "Reshaping History": $"(ansi red_bold)Local Status(ansi reset)"
            "Details": $"(ansi red)✓ clean(ansi reset)"
        })
    } else {
        for line in $status {
            $rows = ($rows | append {
                "Reshaping History": $"(ansi red_bold)Modified(ansi reset)"
                "Details": $"(ansi red)($line | str trim)(ansi reset)"
            })
        }
    }

    $rows
}

def reshaping-history [n: int = 10] {
    let repo = (git rev-parse --show-toplevel | str trim)
    mut results = []

    rh-progress $results "Fetching remote state"
    try { git -C $repo fetch out+err> /dev/null } catch { }
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