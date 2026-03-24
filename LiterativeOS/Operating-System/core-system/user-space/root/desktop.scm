(define-module (core-system user-space root desktop)
  #:use-module (core-system user-space root desktop hyprland)
  #:use-module (core-system user-space root desktop hypridle)
  #:re-export (hyprland hypridle)
  #:export (root-desktop-packages))

(define-public root-desktop-packages
  (list hyprland hypridle))