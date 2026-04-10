(define-module (core-system user-space root loaders wayland)
  #:use-module (core-system user-space root desktop wayland wl-clipboard)
  #:use-module (core-system user-space root desktop wayland grim)
  #:use-module (core-system user-space root desktop wayland slurp)
  #:use-module (core-system user-space root desktop wayland swaylock)
  #:use-module (core-system user-space root desktop wayland wlogout)
  #:use-module (core-system user-space root desktop wayland grimblast)
  #:use-module (core-system user-space root desktop wayland swappy)
  #:re-export (wl-clipboard grim slurp swaylock wlogout grimblast swappy)
  #:export (root-desktop-wayland-packages))

(define-public root-desktop-wayland-packages
  (list wl-clipboard grim slurp swaylock wlogout grimblast swappy))
