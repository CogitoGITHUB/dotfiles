;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders ci)
  #:use-module (core-system user-space root ci cuirass)
  #:re-export (cuirass)
  #:export (root-ci-packages
            root-ci-services))

(define-public root-ci-packages
  (list cuirass))

(define-public root-ci-services
  '())
