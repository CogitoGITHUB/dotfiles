;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders scheduling)
  #:use-module (core-system user-space root scheduling mcron)
  #:re-export (mcron)
  #:export (root-scheduling-packages))

(define-public root-scheduling-packages
  (list mcron))
