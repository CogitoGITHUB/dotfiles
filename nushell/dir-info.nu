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

export def show-dir-info [] {
    let todo_path = ($env.PWD | path join "TODO.org")
    print ""
    print $"(ansi red_bold)  ($env.PWD)(ansi reset)"
    ls -la | reject inode target num_links | print
    if ($todo_path | path exists) {
        print ""
        print $"(ansi red_bold)  TODO(ansi reset)"
        parse-todo $todo_path | print
    }
}

export def open-todo-in-emacs [] {
    let todo_path = ($env.PWD | path join "TODO.org")
    if ($todo_path | path exists) {
        emacs $todo_path
        show-dir-info
    } else {
        print $"(ansi yellow)No TODO.org found in ($env.PWD)(ansi reset)"
    }
}

export def maybe-open-todo [] {
    let todo_path = ($env.PWD | path join "TODO.org")
    show-dir-info
    if ($todo_path | path exists) {
        print ""
        print $"(ansi purple)  Open TODO.org ? [enter=yes, space=no](ansi reset)"
        let key = (input listen --types [key])
        if $key.code == "enter" {
            open-todo-in-emacs
        }
    }
}