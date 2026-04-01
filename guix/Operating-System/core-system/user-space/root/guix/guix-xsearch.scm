(define-module (core-system user-space root guix guix-xsearch)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (guix-xsearch))

(define-public guix-xsearch
  (@@ (gnu packages package-management) guix-xsearch))