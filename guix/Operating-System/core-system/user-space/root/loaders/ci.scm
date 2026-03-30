;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root ci)
  #:use-module (guix packages)
  #:export (ci-packages))

(define-public ci-packages
  '())

(define-module (core-system user-space root loaders ci)
  #:use-module (core-system user-space root ci)
  #:export (ci-packages))
