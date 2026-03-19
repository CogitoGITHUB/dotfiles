;;; Bootloader configuration
(define-public literativeos-keyboard-layout
  (keyboard-layout "us" "dvorak"))

(define-public literativeos-bootloader-configuration
  (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (keyboard-layout literativeos-keyboard-layout)))
