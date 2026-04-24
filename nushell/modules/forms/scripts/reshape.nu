def step-time [t: datetime] {
    let secs = (((date now) - $t) | into int) / 1_000_000_000
    let secs_rounded = ($secs | math round)
    $"($secs_rounded)s"
}

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

def render-table [results: list] {
    $env.config.color_config = ($env.config.color_config | upsert header "red_bold")
    let colored = ($results | each {|row|
        {
            "ManifoldOS Reshaped": $"(ansi red_bold)($row.description)(ansi reset)"
            "": "🌹"
        }
    })
    print ($colored | table --index false)
}

def maybe-open-log [log: string] {
    let choice = (["no" "yes"] | input list --fuzzy "Open log in Emacs?")
    if $choice == "yes" {
        emacsclient --alternate-editor "emacs -nw" -n $log
    } else {
        rm -f $log
    }
}

def reshape [] {
    let manifest = "/ManifoldOS/system.scm"
    let log = $"/tmp/reshape_(date now | format date '%Y%m%d_%H%M%S').log"

    mut results = []
    let start_total = (date now)

    # 1 — Git
    render-progress $results "Committing pending changes"
    let t = (date now)
    try { git -C /ManifoldOS gg out+err>> $log } catch { }
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Repository synchronized" })

    # 2 — Clear cache
    render-progress $results "Clearing Guile cache"
    let t = (date now)
    try { ^/run/setuid-programs/sudo rm -rf /root/.cache/guile/ccache out+err>> $log } catch { }
    try { rm -rf ~/.cache/guile/ccache out+err>> $log } catch { }
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Guile cache cleared" })


    # 3 — Reconfigure
    render-progress $results "Reconfiguring system"
    let t = (date now)
    let r = (^/run/setuid-programs/sudo guix system reconfigure $manifest | complete)
    $r.stdout out>> $log
    $r.stderr out>> $log
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        print -n "\e[2J\e[H"
        print ""

        let all_output = ($r.stdout + "\n" + $r.stderr)
        let error_lines = ($all_output | lines | where { |l| $l =~ "error:" })

        print $"(ansi red_bold)  Reshaping failed because:(ansi reset)"
        print ""
        for line in $error_lines {
            print $"  (ansi red)($line)(ansi reset)"
        }
        print ""

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
        }

        print $"(ansi red_bold)  REPL Output:(ansi reset)"
        print ""
        let repl_out = (^/run/setuid-programs/sudo guix repl $manifest e>| str trim | lines | where { |l|
            not ($l =~ "^;;;" or
                 $l =~ "scheme@" or
                 $l =~ "wrong-type-arg" or
                 $l =~ "open-input-string" or
                 $l =~ "WARNING:" or
                 $l =~ "^$")
        })
        for line in $repl_out {
            print $"  ($line)"
        }
        print ""

        return
    }
    $results = ($results | append { description: "System reconfigured" })


    # 4 — GC
    render-progress $results "Pruning generations and collecting garbage"
    let t = (date now)
    ^/run/setuid-programs/sudo guix gc --delete-generations out+err>> $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Generations pruned & store collected" })

    # Summary
    print -n "\e[2J\e[H"
    print ""
    render-table $results
    print ""
}