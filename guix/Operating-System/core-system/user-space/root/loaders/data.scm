;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders data)
  #:use-module (core-system user-space root data postgresql)
  #:re-export (postgresql)
  #:export (root-data-packages))

(define-public root-data-packages
  (list postgresql))
