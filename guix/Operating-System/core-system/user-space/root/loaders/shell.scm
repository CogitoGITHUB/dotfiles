(define-module (core-system user-space root loaders shell)
  #:use-module (core-system user-space root shell nushell)
  #:use-module (core-system user-space root shell television)
  #:use-module (core-system user-space root shell fzf)
  #:use-module (core-system user-space root shell starship)
  #:use-module (core-system user-space root shell bash)
  #:use-module (core-system user-space root shell zoxide)
  #:use-module (core-system user-space root shell zellij)
  #:use-module (core-system user-space root shell carapace)
  #:use-module (core-system user-space root shell atuin)
  #:use-module (core-system user-space root shell superfile)
  #:use-module (core-system user-space root shell system-monitor)
  #:use-module (core-system user-space root shell power)
  #:use-module (core-system user-space root shell archive)
  #:use-module (core-system user-space root shell fetch neofetch)
  #:use-module (core-system user-space root shell fetch fastfetch)
  #:re-export (nushell fzf starship bash zoxide zellij carapace atuin superfile
               btop htop ncdu glances
               upower tlp acpi
               zip unzip 7zip unrar-free zstd xz
               neofetch fastfetch)
  #:export (root-shell-packages
            root-shell-system-monitor-packages
            root-shell-power-packages
            root-shell-archive-packages
            root-shell-fetch-packages))

(define root-shell-packages
  (list nushell television fzf starship bash zoxide zellij carapace atuin superfile))

(define-public root-shell-system-monitor-packages
  (list btop htop ncdu glances))

(define-public root-shell-power-packages
  (list upower tlp acpi))

(define-public root-shell-archive-packages
  (list zip unzip 7zip unrar-free zstd xz))

(define-public root-shell-fetch-packages
  (list neofetch fastfetch))
