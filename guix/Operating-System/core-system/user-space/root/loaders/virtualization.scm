;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root virtualization)
  #:use-module (guix packages)
  #:export (virtualization-packages))

(define-public virtualization-packages
  '())

(define-module (core-system user-space root loaders virtualization)
  #:use-module (core-system user-space root virtualization)
  #:export (virtualization-packages))
