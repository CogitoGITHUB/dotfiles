(define-module (core-system kernel-space linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services linux)
  #:use-module (guix gexp)
  #:export (kernel kernel-arguments kernel-modules))

;;;;; Linux kernel - linux-libre (free kernel)

(define-public kernel linux-libre)
(define-public kernel-arguments '())

(define kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))
