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
  eza | print
  if ("TODO.org" | path exists) { bat TODO.org }
}

def --env __zoxide_zi [...rest: string] {
  let sel = (try {
    zoxide query --list
    | to text
    | fzf --height=40% --reverse --no-preview
  } catch { "" })
  if ($sel | str trim) != "" { 
    cd ($sel | str trim)
    eza | print
    if ("TODO.org" | path exists) { bat TODO.org }
  }
}

alias eu = __zoxide_z
alias ue = __zoxide_zi