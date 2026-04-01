;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders guix)
  #:use-module (core-system user-space root guix guix)
  #:use-module (core-system user-space root guix guix-modules)
  #:use-module (core-system user-space root guix guix-xsearch)
  #:use-module (core-system user-space root guix gwl)
  #:use-module (core-system user-space root guix bffe)
  #:use-module (core-system user-space root guix guix-build-coordinator)
  #:use-module (core-system user-space root guix hpcguix-web)
  #:use-module (core-system user-space root guix guix-data-service)
  #:re-export (guix guix-modules guix-xsearch gwl bffe guix-build-coordinator hpcguix-web guix-data-service)
  #:export (root-guix-packages
            root-guix-services))

(define-public root-guix-packages
  (list guix guix-modules guix-xsearch gwl bffe guix-build-coordinator hpcguix-web guix-data-service))

(define-public root-guix-services
  '())