(define-module (core-system kernel-space linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services linux)
  #:use-module (guix gexp)
  #:export (kernel kernel-arguments kernel-modules))

(define-public kernel linux-libre)
(define-public kernel-arguments '("snd_intel_dspcfg.dsp_driver=1"))

(define kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))
