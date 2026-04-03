(define-module (core-system kernel-space linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services linux)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (srfi srfi-1)
  #:export (kernel kernel-arguments kernel-modules kernel-initrd kernel-firmware))

(define-public kernel linux)

(define-public kernel-initrd microcode-initrd)

(define-public kernel-firmware (list linux-firmware realtek-firmware wireless-regdb))
(define-public kernel-arguments '("snd_intel_dspcfg.dsp_driver=1" "cfg80211.ieee80211_regdom=US"))

(define-public kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))
