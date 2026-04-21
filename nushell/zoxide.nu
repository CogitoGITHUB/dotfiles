export-env {
  $env.config = (
    $env.config?
    | default {}
    | upsert hooks { default {} }
    | upsert hooks.env_change { default {} }
    | upsert hooks.env_change.PWD { default [] }
  )
  let __zoxide_hooked = (
    $env.config.hooks.env_change.PWD | any { try { get __zoxide_hook } catch { false } }
  )
  if not $__zoxide_hooked {
    $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
      __zoxide_hook: true,
      code: {|_, dir| zoxide add -- $dir}
    })
  }
}

def parse-todo [todo_path: string] {
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

def --env --wrapped __zoxide_z [...rest: string] {
  let path = match $rest {
    []      => { '~' },
    [ '-' ] => { '-' },
    [ $arg ] if ($arg | path type) == 'dir' => { $arg }
    _ => {
      let result = (do { zoxide query --exclude $env.PWD -- ...$rest } | complete)
      if $result.exit_code == 0 { $result.stdout | str trim } else { $rest | str join " " }
    }
  }
  cd $path
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

def --env __zoxide_zi [...rest: string] {
  let sel = (try {
    zoxide query --list
    | to text
    | fzf --height=40% --reverse --no-preview
  } catch { "" })
  if ($sel | str trim) != "" {
    cd ($sel | str trim)
    let todo_path = ($env.PWD | path join "TODO.org")
    print ""
    print $"(ansi red_bold)  ($env.PWD)(ansi reset)"
    ls -la | reject inode  target num_links  | print
    if ($todo_path | path exists) {
      print ""
      print $"(ansi red_bold)  TODO(ansi reset)"
      parse-todo $todo_path | print
    }
  }
}

alias eu = __zoxide_z
alias ue = __zoxide_zi