;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root security sops packages)
  #:use-module (core-system user-space root security sops services)
  #:re-export (sops
               sops-secrets-service-type
               sops-service-configuration)
  #:export (root-security-packages
            root-security-services))

(define-public root-security-packages
  (list sops))

(define-public root-security-services
  '())
