;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders encryption)
  #:use-module (core-system user-space root encryption sops packages)
  #:use-module (core-system user-space root encryption sops services)
  #:use-module (core-system user-space root encryption age)
  #:use-module (core-system user-space root encryption gnupg)
  #:re-export (sops
               sops-secrets-service-type
               sops-service-configuration
               age
               gnupg)
  #:export (root-encryption-packages
            root-encryption-services))

(define-public root-encryption-packages
  (list sops age gnupg))

(define-public root-encryption-services
  '())
