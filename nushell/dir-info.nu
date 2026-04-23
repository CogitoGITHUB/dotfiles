export def parse-todo [todo_path: string] {
    open $todo_path
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
    ]
    for f in $files {
        let fpath = ($env.PWD | path join $f.name)
        if not ($fpath | path exists) {
            $"#+TITLE: ($f.title)\n" | save $fpath
            print $"(ansi yellow)  Created ($f.name)(ansi reset)"
        }
    }
}

export def show-dir-info [] {
    let agents_path    = ($env.PWD | path join "Agents.org")
    let blueprint_path = ($env.PWD | path join "Blueprint.org")
    let rules_path     = ($env.PWD | path join "Rules.org")
    let todo_path      = ($env.PWD | path join "TODO.org")

    print ""
    print $"(ansi red_bold)  ($env.PWD)(ansi reset)"
    ls -la | reject inode target num_links | print

    if ($todo_path | path exists) {
        print ""
        print $"(ansi red_bold)  TODO(ansi reset)"
        parse-todo $todo_path | print
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
    print $"(ansi purple)  [a] Agents  [o] Blueprint  [e] Rules  [u] TODO  [space] skip(ansi reset)"

    let key = (input listen --types [key])

    match $key.code {
        "a" => { open-file-in-emacs ($env.PWD | path join "Agents.org") }
        "o" => { open-file-in-emacs ($env.PWD | path join "Blueprint.org") }
        "e" => { open-file-in-emacs ($env.PWD | path join "Rules.org") }
        "u" => { open-file-in-emacs ($env.PWD | path join "TODO.org") }
        " " => {}
        _   => {}
    }
}