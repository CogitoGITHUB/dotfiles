(define-module (core-system user-space root keyboard keyboard)
  #:use-module (core-system user-space root keyboard keyd)
  #:use-module (core-system user-space root keyboard kanata)
  #:re-export (keyd kanata))