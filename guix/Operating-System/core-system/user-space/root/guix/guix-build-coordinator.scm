(define-module (core-system user-space root guix guix-build-coordinator)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (guix-build-coordinator))

(define-public guix-build-coordinator
  (@@ (gnu packages package-management) guix-build-coordinator))