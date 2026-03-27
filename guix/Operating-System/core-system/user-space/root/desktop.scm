(define-module (core-system user-space root desktop)
  #:use-module (core-system user-space root desktop hyprland)
  #:use-module (core-system user-space root desktop hypridle)
  #:use-module (core-system user-space root desktop qutebrowser)
  #:use-module (core-system user-space root desktop quickshell)
  #:re-export (hyprland hypridle qutebrowser quickshell)
  #:export (root-desktop-packages))

(define-public root-desktop-packages
  (list hyprland hypridle qutebrowser quickshell))