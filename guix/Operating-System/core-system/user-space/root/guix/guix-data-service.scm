(define-module (core-system user-space root guix guix-data-service)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:export (guix-data-service))

(define-public guix-data-service
  (@@ (gnu packages package-management) guix-data-service))