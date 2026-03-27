(define-module (core-system user-space root keyboard)
  #:use-module (core-system user-space root keyboard keyboard)
  #:re-export (keyd kanata)
  #:export (root-keyboard-packages))

(define-public root-keyboard-packages
  (list keyd kanata))