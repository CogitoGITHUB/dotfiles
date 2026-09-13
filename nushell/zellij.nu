# # zellij
 def start_zellij [] {
   if 'ZELLIJ' not-in ($env | columns) {
     let sessions = (
       do { zellij list-sessions } | complete | get stdout
       | ansi strip
       | lines
       | where { |l| $l != "" and ($l | str contains "EXITED") == false }
       | each { |l| $l | split row " " | first | str trim }
     )

     if ($sessions | length) == 0 {
       env ZELLIJ_SOCKET_DIR=/data/data/com.termux/files/home/.cache/zellij zellij
     } else {
       let choice = (
         $sessions | append "[ new session ]"
         | str join "\n"
         | fzf --prompt="zellij > "
       )

       if $choice == "[ new session ]" {
         env ZELLIJ_SOCKET_DIR=/data/data/com.termux/files/home/.cache/zellij zellij
       } else if $choice != "" {
         zellij attach ($choice | str trim)
       }
     }

     if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
       exit
     }
   }
 }

 start_zellij
