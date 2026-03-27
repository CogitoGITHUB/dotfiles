(define-module (core-system user-space root loaders keyboard)
  #:use-module (core-system user-space root keyboard keyd)
  #:use-module (core-system user-space root keyboard kanata)
  #:re-export (keyd kanata)
  #:export (root-keyboard-packages))

(define-public root-keyboard-packages
  (list keyd kanata))