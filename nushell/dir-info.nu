export def parse-org [org_path: string] {
    open $org_path
    | lines
    | each {|line|
        if ($line | str starts-with "* ") {
            let content = ($line | str replace "* " "")
            if ($content | str starts-with "http") {
                {level: 1, kind: "link", description: $content}
            } else {
                {level: 1, kind: "task", description: $content}
            }
        } else if ($line | str starts-with "** ") {
            {level: 2, kind: "note", description: ($line | str replace "** " "")}
        } else { null }
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
}

export def open-file-in-emacs [fpath: string] {
    emacs $fpath
    show-dir-info
}

export def maybe-open-todo [] {
    ensure-workspace-files
    show-dir-info

    print ""
    print $"(ansi purple)  [a] Agents  [o] Blueprint  [e] Rules  [u] TODO  [i] Journal  [d] Context  [h] State  [space] skip(ansi reset)"

    let key = (input listen --types [key])

    match $key.code {
        "a" => { open-file-in-emacs ($env.PWD | path join "Agents.org") }
        "o" => { open-file-in-emacs ($env.PWD | path join "Blueprint.org") }
        "e" => { open-file-in-emacs ($env.PWD | path join "Rules.org") }
        "u" => { open-file-in-emacs ($env.PWD | path join "TODO.org") }
        "i" => { open-file-in-emacs ($env.PWD | path join "Journal.org") }
        "d" => { open-file-in-emacs ($env.PWD | path join "Context.org") }
        "h" => { open-file-in-emacs ($env.PWD | path join "State.org") }
        " " => {}
        _   => {}
    }
}