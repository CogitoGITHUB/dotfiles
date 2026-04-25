# =============================================================================
# ManifoldOS Reshaping History
# =============================================================================
# A git log interface built in the ManifoldOS style.
# Shows recent commit history, repo stats, and current local status
# in a single unified red table.
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

# Clears the screen and renders live progress while fetching repo data.
#
# Parameters:
#   results — list of completed steps
#   current — label for the step currently in progress
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
# SECTION 2 — DATA COLLECTION
# =============================================================================

# Fetches the last N commits with hash, date, and change stats.
# Parses git log and git show --stat into structured rows.
#
# Parameters:
#   n — number of commits to fetch
def fetch-commits [n: int] {
    git log --format="%h|%ad|%s" --date=short -$n
    | lines
    | where { |l| $l | is-not-empty }
    | each { |line|
        let parts = ($line | split row "|")
        let hash = ($parts | get 0)
        let date = ($parts | get 1)
        let stats = (
            git show --stat $hash
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

# Fetches current local status — lists modified, added, or deleted files.
# Returns a list of status lines or empty if working tree is clean.
def fetch-status [] {
    git status --short | lines | where { |l| $l | is-not-empty }
}

# Fetches total commit count and last push time.
def fetch-repo-stats [] {
    let total = (git rev-list --count HEAD | str trim)
    let last_push = (git log -1 --format="%ad" --date=relative | str trim)
    let branch = (git branch --show-current | str trim)
    {
        total: $total
        last_push: $last_push
        branch: $branch
    }
}


# =============================================================================
# SECTION 3 — RENDERING
# =============================================================================

# Renders the unified history table with three sections:
#   - Recent commits (hash, date, stats)
#   - Repo stats (branch, total commits, last push)
#   - Local status (current dirty files or clean)
#
# Parameters:
#   commits — list of commit records from fetch-commits
#   stats   — repo stats record from fetch-repo-stats
#   status  — list of dirty files from fetch-status
def render-history [commits: list, stats: record, status: list] {
    $env.config.color_config = ($env.config.color_config | upsert header "red_bold")

    mut rows = []

    # --- Recent commits ---
    for commit in $commits {
        $rows = ($rows | append {
            "Reshaping History": $"(ansi red_bold)($commit.hash)  ($commit.date)(ansi reset)"
            "": $"(ansi red)($commit.stats)(ansi reset)"
        })
    }

    # --- Divider ---
    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    # --- Repo stats ---
    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)Branch(ansi reset)"
        "": $"(ansi red)($stats.branch)(ansi reset)"
    })
    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)Total Commits(ansi reset)"
        "": $"(ansi red)($stats.total)(ansi reset)"
    })
    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)Last Push(ansi reset)"
        "": $"(ansi red)($stats.last_push)(ansi reset)"
    })

    # --- Divider ---
    $rows = ($rows | append {
        "Reshaping History": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    # --- Local status ---
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

    print ($rows | table --index false)
}


# =============================================================================
# SECTION 4 — MAIN ENTRYPOINT
# =============================================================================

# Main command. Fetches and displays ManifoldOS git history.
#
#   1. Fetch remote state
#   2. Collect commit history, repo stats, local status
#   3. Render unified summary table
#
# Parameters:
#   n — number of recent commits to show (default: 10)
def reshaping-history [n: int = 10] {
    mut results = []

    # --- Step 1: Fetch remote ---
    rh-progress $results "Fetching remote state"
    try { git -C /ManifoldOS fetch out+err> /dev/null } catch { }
    $results = ($results | append { description: "Remote state fetched" })

    # --- Step 2: Collect commit history ---
    rh-progress $results "Reading commit history"
    let commits = (fetch-commits $n)
    $results = ($results | append { description: "Commit history collected" })

    # --- Step 3: Collect repo stats ---
    rh-progress $results "Collecting repo stats"
    let stats = (fetch-repo-stats)
    $results = ($results | append { description: "Repo stats collected" })

    # --- Step 4: Collect local status ---
    rh-progress $results "Checking local status"
    let status = (fetch-status)
    $results = ($results | append { description: "Local status checked" })

    # --- Done: Render unified table ---
    print -n "\e[2J\e[H"
    print ""
    render-history $commits $stats $status
    print ""
}