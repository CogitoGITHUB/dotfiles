def step-time [t: datetime] {
    let secs = (((date now) - $t) | into int) / 1_000_000_000
    let secs_rounded = ($secs | math round)
    $"($secs_rounded)s"
}

def print-banner [text: string] {
    print $"\r(ansi red_bold)╔══════════════════════════════════════╗(ansi reset)"
    print $"(ansi red_bold)║  ($text)  ║(ansi reset)"
    print $"(ansi red_bold)╚══════════════════════════════════════╝(ansi reset)"
    print ""
}

def reshape-test [] {
    let manifest = "/ManifoldOS/system.scm"

    mut results = []
    let start_total = (date now)

    clear
    print ""
    print-banner "       MANIFOLDOS RESHAPING        "

    # 1 — Git
    print -n $"[1/6] Committing pending changes to ManifoldOS..."
    let t = (date now)
    sleep 1sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "1", description: "Repository synchronized", status: "OK", time: $elapsed })
    print $"\r[1/6] OK Repository synchronized ($elapsed)                     "

    # 2 — Root pull
    print -n $"[2/6] Pulling latest Guix channels for root..."
    let t = (date now)
    sleep 2sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "2", description: "Root channels up to date", status: "OK", time: $elapsed })
    print $"\r[2/6] OK Root channels up to date ($elapsed)                    "

    # 3 — User pull
    print -n $"[3/6] Pulling latest Guix channels for user..."
    let t = (date now)
    sleep 2sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "3", description: "User channels up to date", status: "OK", time: $elapsed })
    print $"\r[3/6] OK User channels up to date ($elapsed)                    "

    # 4 — Reconfigure
    print -n $"[4/6] Reconfiguring system from ($manifest)..."
    let t = (date now)
    sleep 3sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "4", description: "System reconfigured", status: "OK", time: $elapsed })
    print $"\r[4/6] OK System reconfigured successfully ($elapsed)            "

    # 5 — GC
    print -n $"[5/6] Pruning all old generations and collecting garbage..."
    let t = (date now)
    sleep 1sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "5", description: "Generations pruned & store collected", status: "OK", time: $elapsed })
    print $"\r[5/6] OK Generations pruned and store collected ($elapsed)      "

    # 6 — Vacuum
    print -n $"[6/6] Vacuuming Guix store database..."
    let t = (date now)
    sleep 1sec
    let elapsed = (step-time $t)
    $results = ($results | append { step: "6", description: "Store database vacuumed", status: "OK", time: $elapsed })
    print $"\r[6/6] OK Store database vacuumed ($elapsed)                     "

    # Summary
    let total_secs = (((date now) - $start_total) | into int) / 1_000_000_000
    let total_rounded = ($total_secs | math round)

    clear
    print ""
    print-banner "          RESHAPE COMPLETE          "
    $env.config.table.mode = "rounded"
    print ($results | table)
    print ""
    print $"(ansi red_bold)ManifoldOS reshape complete in ($total_rounded)s(ansi reset)\n"
}

def reshape [] {
    let manifest = "/ManifoldOS/system.scm"
    let log_dir = ($env.HOME | path join ".config" "reshape" "logs")
    let log = ($log_dir | path join $"(date now | format date '%Y%m%d_%H%M%S').log")
    mkdir $log_dir

    mut results = []
    let start_total = (date now)

    clear
    print ""
    print-banner "       MANIFOLDOS RESHAPING        "

    # 1 — Git
    print -n $"[1/6] Committing pending changes to ManifoldOS..."
    let t = (date now)
    try { git -C /ManifoldOS gg out+err>> $log } catch { }
    let elapsed = (step-time $t)
    $results = ($results | append { step: "1", description: "Repository synchronized", status: "OK", time: $elapsed })
    print $"\r[1/6] OK Repository synchronized ($elapsed)                     "

    # 2 — Root pull
    print -n $"[2/6] Pulling latest Guix channels for root..."
    let t = (date now)
    let r = (^sudo guix pull err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { step: "2", description: "Pull root channels", status: "FAILED", time: $elapsed })
        print $"\r[2/6] FAILED Pull root channels ($elapsed)                   "
        clear
        print-banner "          RESHAPE FAILED               "
        print ($results | table)
        print $"(ansi red_bold)Check log: ($log)(ansi reset)"; exit 1
    }
    $results = ($results | append { step: "2", description: "Root channels up to date", status: "OK", time: $elapsed })
    print $"\r[2/6] OK Root channels up to date ($elapsed)                    "

    # 3 — User pull
    print -n $"[3/6] Pulling latest Guix channels for user..."
    let t = (date now)
    let r = (^guix pull err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { step: "3", description: "Pull user channels", status: "FAILED", time: $elapsed })
        print $"\r[3/6] FAILED Pull user channels ($elapsed)                   "
        clear
        print-banner "          RESHAPE FAILED               "
        print ($results | table)
        print $"(ansi red_bold)Check log: ($log)(ansi reset)"; exit 1
    }
    $results = ($results | append { step: "3", description: "User channels up to date", status: "OK", time: $elapsed })
    print $"\r[3/6] OK User channels up to date ($elapsed)                    "

    # 4 — Reconfigure
    print -n $"[4/6] Reconfiguring system from ($manifest)..."
    let t = (date now)
    let r = (^sudo guix system reconfigure $manifest err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { step: "4", description: "System reconfigure", status: "FAILED", time: $elapsed })
        print $"\r[4/6] FAILED Reconfigure ($elapsed)                          "
        clear
        print-banner "          RESHAPE FAILED               "
        print ($results | table)
        print $"(ansi red_bold)Generations preserved for rollback. Check log: ($log)(ansi reset)"; exit 1
    }
    $results = ($results | append { step: "4", description: "System reconfigured", status: "OK", time: $elapsed })
    print $"\r[4/6] OK System reconfigured successfully ($elapsed)            "

    # 5 — GC with generation cleanup
    print -n $"[5/6] Pruning all old generations and collecting garbage..."
    let t = (date now)
    ^sudo guix gc --delete-generations out+err>> $log
    let elapsed = (step-time $t)
    $results = ($results | append { step: "5", description: "Generations pruned & store collected", status: "OK", time: $elapsed })
    print $"\r[5/6] OK Generations pruned and store collected ($elapsed)      "

    # 6 — Vacuum store database
    print -n $"[6/6] Vacuuming Guix store database..."
    let t = (date now)
    ^sudo guix gc --vacuum-database
    let elapsed = (step-time $t)
    $results = ($results | append { step: "6", description: "Store database vacuumed", status: "OK", time: $elapsed })
    print $"\r[6/6] OK Store database vacuumed ($elapsed)                     "

    # Summary
    let total_secs = (((date now) - $start_total) | into int) / 1_000_000_000
    let total_rounded = ($total_secs | math round)


clear
    print ""
    print-banner "          RESHAPE COMPLETE          "
    $env.config.table.mode = "rounded"
    let colored_results = ($results | each { |row|
        {
            step: $"(ansi red_bold)($row.step)(ansi reset)"
            description: $"(ansi red_bold)($row.description)(ansi reset)"
            status: $"(ansi red_bold)($row.status)(ansi reset)"
            time: $"(ansi red_bold)($row.time)(ansi reset)"
        }
    })
    print ($colored_results | table)
    print ""
    rm $log
    print $"(ansi red_bold)ManifoldOS reshape complete in ($total_rounded)s(ansi reset)\n"
}
