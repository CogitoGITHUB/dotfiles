;;; Bootloader configuration
;; NOTE: GRUB uses its own keyboard layout at boot time.
;; The keyboard-layout defined here is ONLY for GRUB menu navigation.
;; It cannot use keyd/kanata because:
;;   1. GRUB runs before the OS/kernel loads
;;   2. keyd/kanata are userspace daemons that require a running Linux system
;;   3. keyd intercepts keys at the input device layer (/dev/input)
;;   4. GRUB uses a basic VGA/keyboard controller with no input device layer
;; For full keyboard customization (Dvorak, remapped keys), use keyd + kanata
;; which are loaded after the system boots (see kernel/keyboard.scm).

(define-public literativeos-bootloader-configuration
  (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (keyboard-layout literativeos-keyboard-layout)))