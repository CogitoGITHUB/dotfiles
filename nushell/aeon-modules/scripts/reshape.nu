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
    $env.config.color_config = ($env.config.color_config | insert header "red_bold")
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

    # 2 — Root pull
    render-progress $results "Pulling latest Guix channels for root"
    let t = (date now)
    let r = (^sudo guix pull err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { description: "Pull root channels" })
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  Reshape Failed(ansi reset)"
        print ""
        render-table $results
        print $"(ansi red_bold)  Check log: ($log)(ansi reset)"
        emacsclient -n $log
        return
    }
    $results = ($results | append { description: "Root channels up to date" })

    # 3 — User pull
    render-progress $results "Pulling latest Guix channels for user"
    let t = (date now)
    let r = (^guix pull err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { description: "Pull user channels" })
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  Reshape Failed(ansi reset)"
        print ""
        render-table $results
        print $"(ansi red_bold)  Check log: ($log)(ansi reset)"
        emacsclient -n $log
        return
    }
    $results = ($results | append { description: "User channels up to date" })

    # 4 — Reconfigure
    render-progress $results "Reconfiguring system"
    let t = (date now)
    let r = (^sudo guix system reconfigure $manifest err>> $log | complete)
    let elapsed = (step-time $t)
    if $r.exit_code != 0 {
        $results = ($results | append { description: "System reconfigure" })
        print -n "\e[2J\e[H"
        print ""
        print $"(ansi red_bold)  Reshape Failed(ansi reset)"
        print ""
        render-table $results
        print $"(ansi red_bold)  Generations preserved for rollback.(ansi reset)"
        print ""
        emacsclient -n $log
        return
    }
    $results = ($results | append { description: "System reconfigured" })

    # 5 — GC
    render-progress $results "Pruning generations and collecting garbage"
    let t = (date now)
    ^sudo guix gc --delete-generations out+err>> $log
    let elapsed = (step-time $t)
    $results = ($results | append { description: "Generations pruned & store collected" })

    # Summary
    print -n "\e[2J\e[H"
    print ""
    render-table $results
    print ""
    maybe-open-log $log
}