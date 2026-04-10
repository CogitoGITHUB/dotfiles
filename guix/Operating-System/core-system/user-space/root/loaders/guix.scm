(define-module (core-system user-space root loaders guix)
  #:use-module (guix channels)
  #:use-module (gnu services)
  #:use-module (gnu services guix)
  #:use-module (core-system user-space root guix guix)
  #:use-module (core-system user-space root guix guix-modules)
  #:use-module (core-system user-space root guix guix-xsearch)
  #:use-module (core-system user-space root guix gwl)
  #:use-module (core-system user-space root guix bffe)
  #:use-module (core-system user-space root guix guix-build-coordinator)
  #:use-module (core-system user-space root guix hpcguix-web)
  #:use-module (core-system user-space root guix guix-data-service)
  #:use-module (core-system user-space root guix channels)
  #:re-export (guix guix-modules guix-xsearch gwl bffe guix-build-coordinator hpcguix-web guix-data-service)
  #:export (root-guix-packages
            root-guix-services))

(define-public root-guix-packages
  (list guix guix-modules guix-xsearch gwl bffe guix-build-coordinator hpcguix-web guix-data-service))

(define-public root-guix-services
  (list
    (service guix-service-type
      (guix-configuration
        (channels system-channels)))))
