(define-module (core-system user-space root guix hpcguix-web)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (hpcguix-web))

(define-public hpcguix-web
  (@@ (gnu packages package-management) hpcguix-web))