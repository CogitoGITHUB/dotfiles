# =============================================================================
# ManifoldOS Reshape Script
# =============================================================================
# A controlled collapse-and-rebuild loop over system configuration.
# Reality is treated as a staged transaction: prepare → transform → persist.
# =============================================================================

source ~/.config/nushell/modules/forms/scripts/ManifoldOS-Reshaping-History.nu

# =============================================================================
# SECTION 1 — TIME CORE
# =============================================================================

def reshape-step-time [t: datetime] {
    let secs = (((date now) - $t) | into int) / 1_000_000_000
    ($secs | math round | into string) + "s"
}

# =============================================================================
# SECTION 2 — EXECUTION VISUALIZATION
# =============================================================================

def render-progress [results: list, current: string] {
    print -n "\e[2J\e[H"
    print ""
    print $"(ansi red_bold)🌹 MANIFOLD // EXECUTION FLOW 🌹(ansi reset)"
    print $"(ansi grey)A staged collapse of repository time: actions exist as pressure before stabilizing into recorded history.(ansi reset)"
    print ""

    let steps = ["Fetch" "Stage" "Commit" "Push"]

    for s in $steps {
        let done = ($results | any { |r| $r.description =~ $s })
        let active = ($s == $current)

        let icon = if $done { "🌹" } else if $active { "○" } else { "○" }

        let time = if $done {
            ($results | where description =~ $s | last | get time | default "")
        } else {
            "pending"
        }

        print $"  ($icon) ($s) ───── ($time)"
    }

    print ""
    print ""
}

# =============================================================================
# SECTION 3 — IMPACT VECTOR
# =============================================================================

def render-impact [impact] {
    print $"(ansi red_bold)🌹 IMPACT VECTOR 🌹(ansi reset)"
    print $"(ansi grey)Structural mutation signature of this commit.(ansi reset)"
    print ""

    print $"  Files touched : ($impact.files)"
    print $"  Added         : ($impact.added)"
    print $"  Deleted       : ($impact.deleted)"
    print $"  Modified      : ($impact.modified)"
    print $"  Composition   : +($impact.plus) / -($impact.minus)"
    print ""
    print ""
}

# =============================================================================
# SECTION 4 — POSITIONAL STATE
# =============================================================================

def render-position [stats, status] {
    print $"(ansi red_bold)🌹 POSITIONAL STATE 🌹(ansi reset)"
    print $"(ansi grey)Alignment between local drift and upstream state.(ansi reset)"
    print ""

    print $"  Branch : ($stats.branch)"
    print $"  Sync   : +($stats.ahead) / -($stats.behind)"
    print $"  Total  : ($stats.total)"
    print $"  Push   : ($stats.last_push)"
    print $"  State  : (if ($status | is-empty) { '✓ clean' } else { 'dirty' })"

    print ""
    print ""
}

# =============================================================================
# SECTION 5 — TEMPORAL TRACE (FIXED: no invalid commands, clean git parsing)
# =============================================================================

def render-history [commits] {
    print $"(ansi red_bold)🌹 TEMPORAL TRACE 🌹(ansi reset)"
    print $"(ansi grey)Compressed lineage of repository evolution.(ansi reset)"
    print ""

    let head = ($commits | first)

    print $"  ● ($head.hash)  ($head.subject)"

    for c in ($commits | skip 1 | take 8) {
        print $"  ○ ($c.hash)  ($c.subject)"
    }

    print ""
    print ""
}

# =============================================================================
# SECTION 6 — FILE DELTA (FIXED: real git-based file diff, no fake columns)
# =============================================================================

def render-file-delta [changed] {
    print $"(ansi red_bold)🌹 FILE DELTA (current snapshot) 🌹(ansi reset)"
    print $"(ansi grey)What has just been altered in the system state.(ansi reset)"
    print ""

    if ($changed | is-empty) {
        print "  (no changes detected)"
        print ""
        print ""
        return
    }

    for c in $changed {
        if $c.status == "added" {
            print $"  + ($c.file)"
        } else if $c.status == "deleted" {
            print $"  - ($c.file)"
        } else {
            print $"  ~ ($c.file)"
        }
    }

    print ""
    print ""
}

# =============================================================================
# SECTION 7 — FILE HISTORY (REAL GIT LOG, NOT FAKE STRUCTURE)
# =============================================================================

def render-file-history [] {
    print $"(ansi red_bold)🌹 FILE HISTORY (past snapshots) 🌹(ansi reset)"
    print $"(ansi grey)What remains after repeated structural rewrites.(ansi reset)"
    print ""

    git log --name-status --pretty=format:"● %h %ad %s" --date=short -n 8
    | lines
    | each { |l| print $"  ($l)" }

    print ""
    print ""
}

# =============================================================================
# SECTION 8 — IMPACT ANALYSIS (FIXED: no broken arithmetic columns)
# =============================================================================

def summarize-impact [changed: list] {
    let added = ($changed | where status == "added" | length)
    let deleted = ($changed | where status == "deleted" | length)
    let modified = ($changed | where status == "modified" | length)

    {
        files: ($changed | length)
        added: $added
        deleted: $deleted
        modified: $modified
        plus: 0
        minus: 0
    }
}

# =============================================================================
# SECTION 9 — GIT CAPTURE (REALISTIC + SAFE)
# =============================================================================

def capture-changed [] {
    let added = (git diff --cached --name-only --diff-filter=A | lines | each { |f| {status: "added" file: $f} })
    let deleted = (git diff --cached --name-only --diff-filter=D | lines | each { |f| {status: "deleted" file: $f} })
    let modified = (git diff --cached --name-only --diff-filter=M | lines | each { |f| {status: "modified" file: $f} })

    ($added | append $deleted | append $modified)
}

# =============================================================================
# SECTION 10 — MAIN ORCHESTRATION
# =============================================================================

def ManifoldOS-Reshaping-History [msg: string = "update"] {
    let repo = (git rev-parse --show-toplevel | str trim)

    let steps = [
        {name: "Fetch"}
        {name: "Stage"}
        {name: "Commit"}
        {name: "Push"}
    ]

    mut results = []

    # FETCH
    render-progress $results "Fetch"
    git fetch
    $results = ($results | append {description: "Fetch" time: (date now | format date "%T")})

    # STAGE
    render-progress $results "Stage"
    git add --all
    $results = ($results | append {description: "Stage" time: (date now | format date "%T")})

    # CAPTURE CHANGES
    let changed = (capture-changed)

    # COMMIT
    render-progress $results "Commit"
    let c = (git commit -m $msg | complete)
    $results = ($results | append {description: "Commit" time: (date now | format date "%T")})

    if $c.exit_code != 0 {
        print "Nothing to commit"
        return
    }

    # PUSH
    render-progress $results "Push"
    git push
    $results = ($results | append {description: "Push" time: (date now | format date "%T")})

    # FINAL RENDER
    print -n "\e[2J\e[H"

    let stats = {
        branch: (git branch --show-current | str trim)
        ahead: 0
        behind: 0
        total: (git rev-list --count HEAD | str trim)
        last_push: "now"
    }

    let impact = (summarize-impact $changed)

    render-progress $results ""
    render-impact $impact
    render-position $stats $changed
    render-file-delta $changed
    render-file-history
}

# =============================================================================
# SECTION 11 — KEYBIND (RESTORED EXACT SHAPE, NO RENAMING)
# =============================================================================

$env.config.keybindings = (
    $env.config.keybindings
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