# =============================================================================
# ManifoldOS Reshape Script
# =============================================================================
# Handles system reconfiguration via `guix system reconfigure`, with git-based
# version control for all config changes. Git only commits & pushes AFTER a
# successful reconfigure — so the remote always reflects a working system.
#
# ⚠️  DEPENDENCY WARNING
# =============================================================================
# This script sources ManifoldOS-Reshaping-History.nu directly.
# The following functions are available after sourcing:
#
#   - reshaping-history-rows [n: int = 10]
#
# =============================================================================
#
# Flow:
#   1. Capture last-good git commit (current local state)
#   2. Clear Guile cache
#   3. Reconfigure system (guix)
#      ├─ Failure → show build log → show REPL output → offer revert
#      └─ Success → commit & push (git) → GC → unified summary table
# =============================================================================

source ~/.config/nushell/modules/forms/scripts/ManifoldOS-Reshaping-History.nu


# =============================================================================
# SECTION 1 — TIME UTILITIES
# =============================================================================

def step-time [t: datetime] {
    let secs = (((date now) - $t) | into int) / 1_000_000_000
    let secs_rounded = ($secs | math round)
    $"($secs_rounded)s"
}


# =============================================================================
# SECTION 2 — DISPLAY / RENDERING
# =============================================================================

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

    # --- 🌹 EMACS — Control Center ---
    let emacs_status = (try {
        herd status emacs-daemon | str trim
    } catch { "" })

    let emacs_icon = if ($emacs_status =~ "running") {
        $"(ansi red_bold)🌹 running(ansi reset)"
    } else {
        $"(ansi red)🥀 stopped(ansi reset)"
    }

    $rows = ($rows | append {
        "ManifoldOS": $"(ansi red_bold)🌹 Emacs — Control Center(ansi reset)"
        "": $emacs_icon
    })

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
            $current_status = "🌹"
        } else if ($line =~ "^Stopped:") {
            $current_status = "🥀"
        } else if ($line =~ "^Running timers:") {
            $current_status = ""
        } else if ($line =~ "^One-shot:") {
            $current_status = ""
        } else if ($line =~ "^\\s*[+\\-]\\s+\\S" and $current_status != "") {
            let name = ($line | str replace -r "^\\s*[+\\-]\\s+" "" | str trim)
            let should_skip = ($skip_patterns | any { |p| $name | str starts-with $p })
            if (not $should_skip) and ($name | is-not-empty) {
                let status = if $current_status == "🌹" {
                    $"(ansi red)🌹 running(ansi reset)"
                } else {
                    $"(ansi red)🥀 stopped(ansi reset)"
                }
                $rows = ($rows | append {
                    "ManifoldOS": $"(ansi red_bold)($name)(ansi reset)"
                    "": $status
                })
            }
        }
    }

    # --- Divider ---
    $rows = ($rows | append {
        "ManifoldOS": $"(ansi red_bold)─────────────────────────────(ansi reset)"
        "": ""
    })

    # --- Git history (from ManifoldOS-Reshaping-History.nu) ---
    let git_rows = (reshaping-history-rows 10 | rename "ManifoldOS" "")
    $rows = ($rows | append $git_rows)

    print ($rows | table --index false)
}


# =============================================================================
# SECTION 3 — ERROR DISPLAY
# =============================================================================

def render-errors [all_output: string] {
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
        let error_lines = ($all_output | lines | where { |l| $l =~ "error:" })
        print $"(ansi red_bold)  Reshaping failed because:(ansi reset)"
        print ""
        for line in $error_lines {
            print $"  (ansi red)($line)(ansi reset)"
        }
        print ""
    }

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

def capture-last-good [] {
    git -C /ManifoldOS rev-parse HEAD | str trim
}

def git-sync [] {
    # Delegates entirely to ManifoldOS-Reshaping-History.nu
    # To change git behaviour, edit reshaping-push there — not here
    reshaping-push "update"
}

def revert-to-last-good [last_good: string] {
    print $"(ansi yellow_bold)  Last good commit: (ansi reset)(ansi yellow)($last_good | str substring 0..7)(ansi reset)"
    print ""

    let choice = (
        ["no" "yes — revert local files"]
        | input list --fuzzy "Revert local files to last working commit?"
    )

    if ($choice | str starts-with "yes") {
        git -C /ManifoldOS reset --hard $last_good
        print ""
        print $"(ansi green_bold)  ✓ Local files reverted to ($last_good | str substring 0..7)(ansi reset)"
        print ""
    }
}


# =============================================================================
# SECTION 5 — SYSTEM OPERATIONS
# =============================================================================

def clear-guile-cache [log: string] {
    try { ^/run/setuid-programs/sudo rm -rf /root/.cache/guile/ccache out+err>> $log } catch { }
    try { rm -rf ~/.cache/guile/ccache out+err>> $log } catch { }
}

def run-reconfigure [manifest: string, log: string] {
    let r = (^/run/setuid-programs/sudo guix system reconfigure $manifest | complete)
    $r.stdout out>> $log
    $r.stderr out>> $log
    $r
}

def run-gc [log: string] {
    ^/run/setuid-programs/sudo guix system delete-generations 3m out+err>> $log
}


# =============================================================================
# SECTION 6 — MAIN RESHAPE ENTRYPOINT
# =============================================================================

def ManifoldOS-Reshaping [] {
    let manifest = "/ManifoldOS/system.scm"
    let log = $"/tmp/reshape_(date now | format date '%Y%m%d_%H%M%S').log"

    mut results = []

    let last_good = (capture-last-good)

    # --- Step 1: Clear Guile cache ---
    render-progress $results "Clearing Guile cache"
    let t = (date now)
    clear-guile-cache $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Guile cache cleared" })

    # --- Step 2: Reconfigure ---
    render-progress $results "Reconfiguring system"
    let t = (date now)
    let r = (run-reconfigure $manifest $log)
    let elapsed = (step-time $t)

    if $r.exit_code != 0 {
        print -n "\e[2J\e[H"
        print ""
        let all_output = ($r.stdout + "\n" + $r.stderr)
        render-errors $all_output
        revert-to-last-good $last_good
        return
    }

    $results = ($results | append { description: "System reconfigured" })

    # --- Step 3: Git commit & push ---
    render-progress $results "Committing working state"
    let t = (date now)
    git-sync
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


# =============================================================================
# SECTION 7 — KEYBINDING
# =============================================================================

$env.config.keybindings = ($env.config.keybindings | append {
    name: ManifoldOS_Reshaping
    modifier: control
    keycode: char_s
    mode: emacs
    event: {
        send: executehostcommand
        cmd: "ManifoldOS-Reshaping"
    }
})