(define-module (core-system user-space root loaders desktop)
  #:use-module (core-system user-space root desktop hyprland)
  #:use-module (core-system user-space root desktop hypridle)
  #:use-module (core-system user-space root desktop qutebrowser)
  #:use-module (core-system user-space root desktop quickshell)
  #:use-module (core-system user-space root desktop mako)
  #:re-export (hyprland hypridle qutebrowser quickshell mako)
  #:export (root-desktop-packages))

(define-public root-desktop-packages
  (list hyprland hypridle qutebrowser quickshell mako))
