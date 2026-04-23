export def parse-org [org_path: string] {
    open $org_path
    | lines
    | each {|line|
        try {
            let level = ($line | parse -r '^(\*+) ' | get capture0.0? | default "" | str length)
            if $level > 0 {
                let content = ($line | str replace -r '^\*+ ' "")
                if ($content | str starts-with "http") {
                    {level: $level, kind: "link", description: $content}
                } else {
                    {level: $level, kind: "task", description: $content}
                }
            } else { null }
        } catch { null }
    }
    | compact
}

def ensure-workspace-files [] {
    let files = [
        { name: "Agents.org",    title: "Agents" }
        { name: "Blueprint.org", title: "Blueprint" }
        { name: "Rules.org",     title: "Rules" }
        { name: "TODO.org",      title: "TODO" }
        { name: "Journal.org",   title: "Journal" }
        { name: "Context.org",   title: "Context" }
        { name: "State.org",     title: "State" }
        { name: "Laws.org",      title: "Laws" }  # added
    ]
    for f in $files {
        let fpath = ($env.PWD | path join $f.name)
        if not ($fpath | path exists) {
            $"#+TITLE: ($f.title)\n" | save $fpath
        }
    }
}

export def show-dir-info [] {
    let todo_path    = ($env.PWD | path join "TODO.org")
    let journal_path = ($env.PWD | path join "Journal.org")
    let state_path   = ($env.PWD | path join "State.org")
    let laws_path    = ($env.PWD | path join "Laws.org")  # added
    let dir_name     = ($env.PWD | path basename)

    print ""
    print ($env.PWD | path split)
    print $"(ansi red_bold)  ($dir_name)(ansi reset)"
    ls -la | reject inode target num_links | print

    if ($todo_path | path exists) {
        print ""
        print $"(ansi red_bold)  TODO(ansi reset)"
        parse-org $todo_path | print
    }

    if ($journal_path | path exists) {
        print ""
        print $"(ansi red_bold)  JOURNAL(ansi reset)"
        parse-org $journal_path | print
    }

    if ($state_path | path exists) {
        print ""
        print $"(ansi red_bold)  STATE(ansi reset)"
        parse-org $state_path | print
    }

    if ($laws_path | path exists) {  # added
        print ""
        print $"(ansi red_bold)  LAWS(ansi reset)"
        parse-org $laws_path | print
    }
}

def show-prompt [] {
    print ""
    print $"(ansi purple)  [a] Agents  [o] Blueprint  [e] Rules  [u] TODO  [i] Journal  [d] Context  [h] State  [t] Laws  [space] skip(ansi reset)"

    let key = (input listen --types [key])

    match $key.code {
        "a" => { open-file-in-emacs ($env.PWD | path join "Agents.org") }
        "o" => { open-file-in-emacs ($env.PWD | path join "Blueprint.org") }
        "e" => { open-file-in-emacs ($env.PWD | path join "Rules.org") }
        "u" => { open-file-in-emacs ($env.PWD | path join "TODO.org") }
        "i" => { open-file-in-emacs ($env.PWD | path join "Journal.org") }
        "d" => { open-file-in-emacs ($env.PWD | path join "Context.org") }
        "h" => { open-file-in-emacs ($env.PWD | path join "State.org") }
        "t" => { open-file-in-emacs ($env.PWD | path join "Laws.org") }  # added
        " " => { clear; show-dir-info }
        _   => { clear; show-dir-info }
    }
}

export def open-file-in-emacs [fpath: string] {
    emacs $fpath
    clear
    show-dir-info
    show-prompt
}

export def maybe-open-todo [] {
    ensure-workspace-files
    clear
    show-dir-info
    show-prompt
}