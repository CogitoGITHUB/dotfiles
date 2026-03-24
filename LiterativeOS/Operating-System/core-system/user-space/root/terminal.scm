(define-module (core-system user-space root terminal)
  #:use-module (core-system user-space root terminal wezterm)
  #:re-export (wezterm)
  #:export (root-terminal-packages))

(define-public root-terminal-packages
  (list wezterm))