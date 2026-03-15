;; LiterativeOS - Bootloader Configuration
;; Exports: literativeos-bootloader

(define literativeos-bootloader
  (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets (list "/boot/efi"))))
