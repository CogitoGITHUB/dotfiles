def fzf-open [
    path?: string
] {
    let root = ($path | default ".")

    let file = (
        fd --type f . $root
        | str join "\n"
        | fzf
            --preview "bat --color=always --style=numbers {}"
            --preview-window "right:60%:wrap"
            --prompt "  File> "
            --header "ENTER to select"
        | str trim
    )

    if ($file | is-empty) { return }

    let action = (
        ["bat" "emacs" "nvim"]
        | str join "\n"
        | fzf
            --prompt "  Action> "
            --header $"($file) — ↑↓ to pick  ENTER to open"
            --height 20%
            --no-preview
        | str trim
    )

    match $action {
        "bat"   => { bat --color=always $file }
        "emacs" => { ^emacs $file }
        "nvim"  => { ^nvim $file }
        _       => { print "No action taken." }
    }
}

def fzf-grep [
    query?: string
] {
    let q = ($query | default "")

    let result = (
        rg --color=always --line-number --no-heading --smart-case ""
        | fzf
            --ansi
            --query $q
            --delimiter ":"
            --preview "bat --color=always --style=numbers --highlight-line {2} {1}"
            --preview-window "right:60%:+{2}+3/3:wrap"
            --prompt "  Grep> "
            --header "ENTER to select"
            --bind "change:reload:rg --color=always --line-number --no-heading --smart-case {q} || true"
        | str trim
    )

    if ($result | is-empty) { return }

    let parts = ($result | split row ":")
    let file  = ($parts | first)
    let line  = ($parts | get 1 | into int)

    let action = (
        ["bat" "emacs" "nvim"]
        | str join "\n"
        | fzf
            --prompt "  Action> "
            --header $"($file):($line) — ↑↓ to pick  ENTER to open"
            --height 20%
            --no-preview
        | str trim
    )

    match $action {
        "bat"   => { bat --color=always $file }
        "emacs" => { ^emacs $"+($line)" $file }
        "nvim"  => { ^nvim $"+($line)" $file }
        _       => { print "No action taken." }
    }
}

$env.config.keybindings ++= [
    {
        name: fzf_file_open
        modifier: CONTROL
        keycode: char_f
        mode: [emacs, vi_insert, vi_normal]
        event: { send: executehostcommand cmd: "fzf-open" }
    }
]