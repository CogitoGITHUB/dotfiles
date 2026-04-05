(define-module (core-system user-space root audio pipewire)
  #:use-module (gnu packages linux)
  #:export (pipewire wireplumber))

(define-public pipewire (@ (gnu packages linux) pipewire))
(define-public wireplumber (@ (gnu packages linux) wireplumber))