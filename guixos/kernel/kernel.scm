;; Kernel configuration - uses system Guix packages

(define-module (kernel)
  #:use-module (gnu packages linux)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub))

;; Re-exports
(define-public literativeos-kernel linux-libre)
(define-public literativeos-firmware '())
(define-public literativeos-bootloader
  (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets (list "/boot/efi"))))
