(define-module (core-system user-space root guix guix)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (guix))

(define-public guix
  (@@ (gnu packages package-management) guix))