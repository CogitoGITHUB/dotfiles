;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root scheduling jobs)
  #:use-module (guix packages)
  #:export (jobs-packages))

(define-public jobs-packages
  '())

(define-module (core-system user-space root loaders scheduling)
  #:use-module (core-system user-space root scheduling jobs)
  #:export (scheduling-packages))
