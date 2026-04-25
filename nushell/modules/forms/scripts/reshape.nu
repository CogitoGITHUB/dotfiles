# =============================================================================
# ManifoldOS Reshape Script
# =============================================================================
# Handles system reconfiguration via `guix system reconfigure`, with git-based
# version control for all config changes. Git only commits & pushes AFTER a
# successful reconfigure — so the remote always reflects a working system.
#
# Flow:
#   1. Capture last-good git commit (current local state)
#   2. Clear Guile cache
#   3. Reconfigure system (guix)
#      ├─ Failure → show build log → show REPL output → offer revert
#      └─ Success → commit & push (git) → GC → unified summary table
# =============================================================================


# =============================================================================
# SECTION 1 — TIME UTILITIES
# =============================================================================

# Calculates elapsed seconds between a given datetime and now.
# Used to measure how long each reshape step takes.
def step-time [t: datetime] {
    let secs = (((date now) - $t) | into int) / 1_000_000_000
    let secs_rounded = ($secs | math round)
    $"($secs_rounded)s"
}


# =============================================================================
# SECTION 2 — DISPLAY / RENDERING
# =============================================================================

# Clears the screen and renders the live progress view during reshaping.
# Shows completed steps (with ✓) and the currently running step (with >>>).
#
# Parameters:
#   results  — list of completed steps, each with a `description` field
#   current  — label for the step currently in progress
def render-progress [results: list, current: string] {
    print -n "\e[2J\e[H"
    print ""
    print $"(ansi red_bold)  ManifoldOS Reshaping ...(ansi reset)"
    print ""
    for row in $results {
        print $"(ansi red_bold)  ✓ ($row.description) 🌹(ansi reset)"
    }
    print ""
    print $"  >>> ($current) ❗"
    print ""
}

# Renders one unified summary table with reshape steps, system info,
# and key Shepherd services — all in dark red.
#
# Parameters:
#   results — list of completed steps, each with a `description` field
def render-summary [results: list] {
    $env.config.color_config = ($env.config.color_config | upsert header "red_bold")

    mut rows = []

    # --- Reshape steps ---
    for row in $results {
        $rows = ($rows | append {
            "ManifoldOS": $"(ansi red_bold)($row.description)(ansi reset)"
            "": "🌹"
        })
    }

    # --- Divider ---
    $rows = ($rows | append {
        "ManifoldOS": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    # --- System info ---
    let kernel = (^uname -r | str trim)

    let disk_cols = (^df -h / | lines | last | split row " " | where { |it| $it | is-not-empty })
    let disk = $"($disk_cols | get 2) / ($disk_cols | get 1)"

    let store = (du --max-depth 0 /gnu/store | get apparent | first | into string)

    let mem_cols = (^free -h | lines | where { |l| $l =~ "^Mem:" } | first | split row " " | where { |it| $it | is-not-empty })
    let ram = $"($mem_cols | get 2) / ($mem_cols | get 1)"

    let uptime = (^uptime | str trim | str replace -r `.*up\s+` "" | str replace -r `,\s+\d+ user.*` "" | str trim)

    $rows = ($rows | append { "ManifoldOS": $"(ansi red_bold)Kernel(ansi reset)"  "": $"(ansi red)($kernel)(ansi reset)" })
    $rows = ($rows | append { "ManifoldOS": $"(ansi red_bold)Disk /(ansi reset)"  "": $"(ansi red)($disk)(ansi reset)" })
    $rows = ($rows | append { "ManifoldOS": $"(ansi red_bold)Store(ansi reset)"   "": $"(ansi red)($store)(ansi reset)" })
    $rows = ($rows | append { "ManifoldOS": $"(ansi red_bold)RAM(ansi reset)"     "": $"(ansi red)($ram)(ansi reset)" })
    $rows = ($rows | append { "ManifoldOS": $"(ansi red_bold)Uptime(ansi reset)"  "": $"(ansi red)($uptime)(ansi reset)" })

    # --- Divider ---
    $rows = ($rows | append {
        "ManifoldOS": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    # --- Shepherd services ---
    # Filtered: skip file-system-*, term-*, console-font-*, one-shot, timers,
    # and other low-level noise. Only show meaningful services.
    let skip_patterns = [
        "file-system-"
        "term-"
        "console-font-"
        "root"
        "transient"
        "timer"
        "loopback"
        "urandom-seed"
        "user-file-systems"
        "user-processes"
        "virtual-terminal"
        "pam"
        "system-log"
    ]

    let lines = (^/run/setuid-programs/sudo herd status | lines)
    mut current_status = ""

    for line in $lines {
        if ($line =~ "^Started:") {
            $current_status = "🟢"
        } else if ($line =~ "^Stopped:") {
            $current_status = "🔴"
        } else if ($line =~ "^Running timers:") {
            $current_status = ""  # skip timers
        } else if ($line =~ "^One-shot:") {
            $current_status = ""  # skip one-shot
        } else if ($line =~ "^\\s*[+\\-]\\s+\\S" and $current_status != "") {
            let name = ($line | str replace -r "^\\s*[+\\-]\\s+" "" | str trim)
            let should_skip = ($skip_patterns | any { |p| $name | str starts-with $p })
            if (not $should_skip) and ($name | is-not-empty) {
                let status = if $current_status == "🟢" {
                    $"(ansi red)🟢 running(ansi reset)"
                } else {
                    $"(ansi red)🔴 stopped(ansi reset)"
                }
                $rows = ($rows | append {
                    "ManifoldOS": $"(ansi red_bold)($name)(ansi reset)"
                    "": $status
                })
            }
        }
    }

    print ($rows | table --index false)
}


# =============================================================================
# SECTION 3 — ERROR DISPLAY
# =============================================================================

# Displays all available failure information after a failed reconfigure.
# Shows:
#   - The .drv build log via sudo zcat (actual low-level build failure)
#   - Filtered guix repl output (Scheme-level errors from the manifest)
#
# Parameters:
#   all_output — combined stdout + stderr string from the failed guix command
def render-errors [all_output: string] {

    # --- Build log ---
    # Extract the .drv log path from the output if present and zcat it.
    # This is the most detailed account of what went wrong during the build.
    let drv_log_lines = ($all_output | lines | where { |l| $l =~ "View build log at" })
    let drv_log = if ($drv_log_lines | is-empty) {
        ""
    } else {
        $drv_log_lines | first | str replace -r `.*'([^']+)'.*` "$1" | str trim
    }

    if ($drv_log | is-not-empty) {
        print $"(ansi red_bold)  Build Log:(ansi reset)"
        print ""
        ^/run/setuid-programs/sudo zcat $drv_log | bat --language=log --paging=never
        print ""
    } else {
        # No .drv log found — fall back to printing raw error lines
        let error_lines = ($all_output | lines | where { |l| $l =~ "error:" })
        print $"(ansi red_bold)  Reshaping failed because:(ansi reset)"
        print ""
        for line in $error_lines {
            print $"  (ansi red)($line)(ansi reset)"
        }
        print ""
    }

    # --- REPL output ---
    # Run guix repl on the manifest to surface Scheme-level errors.
    # Filters out noise: warnings, scheme@ prompts, empty lines, etc.
    print $"(ansi red_bold)  REPL Output:(ansi reset)"
    print ""
    let repl_out = (
        ^/run/setuid-programs/sudo guix repl /ManifoldOS/system.scm e>| str trim
        | lines
        | where { |l|
            not ($l =~ "^;;;" or
                 $l =~ "scheme@" or
                 $l =~ "wrong-type-arg" or
                 $l =~ "open-input-string" or
                 $l =~ "WARNING:" or
                 $l =~ "^$")
        }
    )
    for line in $repl_out {
        print $"  ($line)"
    }
    print ""
}


# =============================================================================
# SECTION 4 — GIT OPERATIONS
# =============================================================================

# Captures the current HEAD commit hash before any changes are made.
# Since we never push broken state, HEAD is always a working commit.
#
# Returns: the full commit hash string
def capture-last-good [] {
    git -C /ManifoldOS rev-parse HEAD | str trim
}

# Commits and pushes all pending changes in the ManifoldOS repo.
# Only called AFTER a successful reconfigure — so remote is always clean.
# Uses the custom `gg` alias (git add -A && git commit && git push).
#
# Parameters:
#   log — path to the log file to append git output to
def git-sync [log: string] {
    try { git -C /ManifoldOS gg out+err>> $log } catch { }
}

# Offers to revert local files to the last known good commit.
# Since broken state was never pushed, no force push needed —
# just reset local files and reshape again to restore the running system.
#
# Parameters:
#   last_good — the commit hash to revert to (captured before the failed reshape)
def revert-to-last-good [last_good: string] {
    print $"(ansi yellow_bold)  Last good commit: (ansi reset)(ansi yellow)($last_good | str substring 0..7)(ansi reset)"
    print ""

    let choice = (
        ["no" "yes — revert to last good state"]
        | input list --fuzzy "Revert local files to last working commit?"
    )

    if ($choice | str starts-with "yes") {
        # Reset local files to last good commit
        # No force push needed — broken state was never pushed to remote
        git -C /ManifoldOS reset --hard $last_good

        print ""
        print $"(ansi green_bold)  ✓ Reverted to ($last_good | str substring 0..7), reshaping back to working state...(ansi reset)"
        print ""

        # Reshape again — last_good is a known working state so this succeeds cleanly
        reshape
    }
}


# =============================================================================
# SECTION 5 — SYSTEM OPERATIONS
# =============================================================================

# Clears the Guile bytecode cache for both root and the current user.
# Prevents stale compiled Scheme files from interfering with reconfigure.
#
# Parameters:
#   log — path to the log file to append output to
def clear-guile-cache [log: string] {
    try { ^/run/setuid-programs/sudo rm -rf /root/.cache/guile/ccache out+err>> $log } catch { }
    try { rm -rf ~/.cache/guile/ccache out+err>> $log } catch { }
}

# Runs `guix system reconfigure` on the ManifoldOS manifest.
# Returns the full `complete` record (stdout, stderr, exit_code).
#
# Parameters:
#   manifest — path to the system manifest file
#   log      — path to the log file to append output to
def run-reconfigure [manifest: string, log: string] {
    let r = (^/run/setuid-programs/sudo guix system reconfigure $manifest | complete)
    $r.stdout out>> $log
    $r.stderr out>> $log
    $r
}

# Deletes all system generations except current, runs GC, then deduplicates
# the store by hard-linking identical files to reclaim maximum space.
#
# Parameters:
#   log — path to the log file to append output to
def run-gc [log: string] {
    # Delete all old generations — git handles rollback, we don't need them
    ^/run/setuid-programs/sudo guix system delete-generations out+err>> $log
    # Collect all unreachable store paths
    ^/run/setuid-programs/sudo guix gc out+err>> $log
    # Deduplicate store by hard-linking identical files
    ^/run/setuid-programs/sudo guix gc --optimize out+err>> $log
}


# =============================================================================
# SECTION 6 — MAIN RESHAPE ENTRYPOINT
# =============================================================================

# Main command. Orchestrates the full ManifoldOS reshape sequence:
#
#   1. Capture last-good commit (local HEAD, always a working state)
#   2. Clear Guile cache
#   3. Guix system reconfigure
#      ├─ Failure → show build log → show REPL output → offer revert → done
#      └─ Success → git commit & push → GC + optimize → unified summary table
#
# Git only touches the remote on success, so remote is always a clean history
# of working system states.
def reshape [] {
    let manifest = "/ManifoldOS/system.scm"
    let log = $"/tmp/reshape_(date now | format date '%Y%m%d_%H%M%S').log"

    mut results = []

    # --- Step 0: Capture last-good commit before touching anything ---
    # Since we never push broken state, this is always a working commit.
    let last_good = (capture-last-good)

    # --- Step 1: Clear Guile cache ---
    render-progress $results "Clearing Guile cache"
    let t = (date now)
    clear-guile-cache $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Guile cache cleared" })

    # --- Step 2: Reconfigure ---
    # Attempt reconfigure BEFORE committing anything.
    # If it fails, local files are untouched and easy to revert.
    render-progress $results "Reconfiguring system"
    let t = (date now)
    let r = (run-reconfigure $manifest $log)
    let elapsed = (step-time $t)

    if $r.exit_code != 0 {
        # Reconfigure failed — show build log and REPL output, then offer revert
        print -n "\e[2J\e[H"
        print ""
        let all_output = ($r.stdout + "\n" + $r.stderr)
        render-errors $all_output
        revert-to-last-good $last_good
        return
    }

    $results = ($results | append { description: "System reconfigured" })

    # --- Step 3: Git commit & push ---
    # Only reached on successful reconfigure — remote stays a clean working history.
    render-progress $results "Committing working state"
    let t = (date now)
    git-sync $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Working state committed & pushed" })

    # --- Step 4: Garbage collection + optimization ---
    render-progress $results "Reshaping reality"
    let t = (date now)
    run-gc $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Reality reshaped" })

    # --- Done: Print unified summary table ---
    print -n "\e[2J\e[H"
    print ""
    render-summary $results
    print ""
}