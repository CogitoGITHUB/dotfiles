;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root data)
  #:use-module (guix packages)
  #:export (data-packages))

(define-public data-packages
  '())

(define-module (core-system user-space root loaders data)
  #:use-module (core-system user-space root data)
  #:export (data-packages))
