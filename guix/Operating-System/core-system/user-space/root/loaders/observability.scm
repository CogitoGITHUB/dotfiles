;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders observability)
  #:use-module (core-system user-space root observability metrics)
  #:use-module (core-system user-space root observability visualization)
  #:use-module (core-system user-space root observability logging)
  #:export (observability-packages))

(define-public observability-packages
  (append metrics-packages
          visualization-packages
          logging-packages))
