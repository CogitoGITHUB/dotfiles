(define-module (core-system user-space root guix bffe)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (bffe))

(define-public bffe
  (@@ (gnu packages package-management) bffe))