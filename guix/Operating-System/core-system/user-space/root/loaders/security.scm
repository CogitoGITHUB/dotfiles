;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root security auth)
  #:use-module (core-system user-space root security secrets)
  #:export (security-packages))

(define-public security-packages
  (append auth-packages
          security-secrets-packages))
