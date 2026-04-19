def zellij-clean [] {
  zellij ls | ansi strip | lines | where { |l| ($l | str contains "current") == false } | each { |l| zellij delete-session --force ($l | split row " " | first | str trim) }
}

alias cd = __zoxide_z

alias e = emacs
alias d = emacs .
alias t = emacs TODO.org
alias n = nvim

alias o = opencode

