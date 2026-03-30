;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root hardware)
  #:use-module (guix packages)
  #:export (hardware-packages))

(define-public hardware-packages
  '())

(define-module (core-system user-space root loaders hardware)
  #:use-module (core-system user-space root hardware)
  #:export (hardware-packages))
