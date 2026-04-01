(define-module (core-system user-space root guix gwl)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (gwl))

(define-public gwl
  (@@ (gnu packages package-management) gwl))