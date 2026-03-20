;;;;; Linux kernel - linux-libre (free kernel)
(use-modules (gnu packages linux)
             (gnu services)
             (gnu services linux)
             (guix gexp))

(define-public literativeos-kernel linux-libre)
(define-public literativeos-kernel-arguments '())

(define literativeos-kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))
