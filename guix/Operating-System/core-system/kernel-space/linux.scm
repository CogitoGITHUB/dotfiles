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

(define-public kernel
  (package
    (inherit (corrupt-linux linux-libre-6.18
                            #:configs '()))
    (name "linux-with-regdb-fix")
    (source
     (origin
       (inherit (package-source linux-libre-6.18))
       (snippet
        #~(begin
            (when (file-exists? "arch/x86/configs/guix_defconfig")
              (let ((defconfig "arch/x86/configs/guix_defconfig"))
                (substitute* defconfig
                  (("CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y")
                   "CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=n")
                  (("CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y")
                   "CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=n"))
                (format #t "Patched ~a~%" defconfig)))))))))

(define-public kernel-initrd microcode-initrd)

(define-public kernel-firmware (list linux-firmware))
(define-public kernel-arguments '("snd_intel_dspcfg.dsp_driver=1"))

(define-public kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))
