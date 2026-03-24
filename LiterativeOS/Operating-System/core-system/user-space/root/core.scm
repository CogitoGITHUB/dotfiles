(define-module (core-system user-space root core)
  #:use-module (gnu packages base)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages version-control)
  #:export (root-core-packages))

(define root-core-packages
  (list coreutils findutils grep inetutils kmod sudo util-linux))
