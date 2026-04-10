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
  #:use-module (core-system user-space root shell system-monitor btop)
  #:use-module (core-system user-space root shell system-monitor htop)
  #:use-module (core-system user-space root shell system-monitor ncdu)
  #:use-module (core-system user-space root shell system-monitor glances)
  #:use-module (core-system user-space root shell power upower)
  #:use-module (core-system user-space root shell power tlp)
  #:use-module (core-system user-space root shell power acpi)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive zstd)
  #:use-module (core-system user-space root shell archive xz)
  #:use-module (core-system user-space root shell fetch neofetch)
  #:use-module (core-system user-space root shell fetch fastfetch)
  #:use-module (core-system user-space root shell rip)
  #:re-export (nushell television fzf starship bash zoxide zellij carapace atuin superfile rip-cli
htop ncdu glances
               upower tlp acpi
               unzip zstd xz
               neofetch fastfetch)
  #:export (root-shell-packages
            root-shell-system-monitor-packages
            root-shell-power-packages
            root-shell-archive-packages
            root-shell-fetch-packages))

(define root-shell-packages
  (list nushell television fzf starship bash zoxide zellij carapace atuin superfile rip-cli))

(define-public root-shell-system-monitor-packages
  (list btop htop ncdu glances))

(define-public root-shell-power-packages
  (list upower tlp acpi))

(define-public root-shell-archive-packages
  (list unzip zstd xz))

(define-public root-shell-fetch-packages
  (list neofetch fastfetch))
