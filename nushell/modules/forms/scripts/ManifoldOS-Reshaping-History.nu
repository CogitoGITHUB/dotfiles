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
#       Returns a list of records with columns "Reshaping History" and ""
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
#   - rh-progress (internal progress renderer)
#   - Visual styling inside reshaping-history-rows (colors, dividers, labels)
#     as long as the column names stay the same
# =============================================================================
#
# Flow:
#   1. Fetch latest remote state
#   2. Build commit history table
#   3. Repo stats
#   4. Current local status
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
    git -C /ManifoldOS log --format="%h|%ad|%s" --date=short $"-($n)"
    | lines
    | where { |l| $l | is-not-empty }
    | each { |line|
        let parts = ($line | split row "|")
        let hash = ($parts | get 0)
        let date = ($parts | get 1)
        let stats = (
            git -C /ManifoldOS show --stat $hash
            | lines
            | last
            | str trim
        )
        {
            hash: $hash
            date: $date
            stats: $stats
        }
    }
}

def fetch-status [] {
    git -C /ManifoldOS status --short | lines | where { |l| $l | is-not-empty }
}

def fetch-repo-stats [] {
    let total = (git -C /ManifoldOS rev-list --count HEAD | str trim)
    let last_push = (git -C /ManifoldOS log -1 --format="%ad" --date=relative | str trim)
    let branch = (git -C /ManifoldOS branch --show-current | str trim)
    {
        total: $total
        last_push: $last_push
        branch: $branch
    }
}


# =============================================================================
# SECTION 3 — RENDERING (public API — see warning above)
# =============================================================================

# Returns rows for embedding in other scripts' tables.
# Column names must stay as "Reshaping History" and "" — consumers depend on this.
def reshaping-history-rows [n: int = 10] {
    let commits = (fetch-commits $n)
    let stats = (fetch-repo-stats)
    let status = (fetch-status)

    mut rows = []

    for commit in $commits {
        $rows = ($rows | append {
            "Reshaping History": $"(ansi red_bold)($commit.hash)  ($commit.date)(ansi reset)"
            "": $"(ansi red)($commit.stats)(ansi reset)"
        })
    }

    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Branch(ansi reset)"        "": $"(ansi red)($stats.branch)(ansi reset)" })
    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Total Commits(ansi reset)" "": $"(ansi red)($stats.total)(ansi reset)" })
    $rows = ($rows | append { "Reshaping History": $"(ansi red_bold)Last Push(ansi reset)"     "": $"(ansi red)($stats.last_push)(ansi reset)" })

    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    if ($status | is-empty) {
        $rows = ($rows | append {
            "Reshaping History": $"(ansi red_bold)Local Status(ansi reset)"
            "": $"(ansi red)✓ clean(ansi reset)"
        })
    } else {
        for line in $status {
            $rows = ($rows | append {
                "Reshaping History": $"(ansi red_bold)Modified(ansi reset)"
                "": $"(ansi red)($line | str trim)(ansi reset)"
            })
        }
    }

    $rows
}

# Safe to change freely — only used by the keybinding below.
def reshaping-history [n: int = 10] {
    mut results = []

    rh-progress $results "Fetching remote state"
    try { git -C /ManifoldOS fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    rh-progress $results "Building history"
    $results = ($results | append { description: "History built" })

    print -n "\e[2J\e[H"
    print ""
    print (reshaping-history-rows $n | table --index false)
    print ""
}


# =============================================================================
# SECTION 4 — KEYBINDING
# =============================================================================

$env.config.keybindings = ($env.config.keybindings | append {
    name: ManifoldOS_Reshaping_History
    modifier: control
    keycode: char_g
    mode: emacs
    event: {
        send: executehostcommand
        cmd: "source ~/.config/nushell/modules/forms/scripts/ManifoldOS-Reshaping-History.nu; reshaping-history"
    }
})