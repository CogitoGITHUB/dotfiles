(define-module (core-system user-space root guix guix-modules)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (guix-modules))

(define-public guix-modules
  (@@ (gnu packages package-management) guix-modules))