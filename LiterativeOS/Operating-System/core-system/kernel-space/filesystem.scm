(define-module (core-system kernel-space filesystem)
  #:use-module (gnu system file-systems)
  #:export (file-systems))

;;; File system configuration
(define-public file-systems
  (cons* (file-system
           (mount-point "/boot/efi")
           (device (uuid "84F3-3015" 'fat32))
           (type "vfat"))
         (file-system
           (mount-point "/")
           (device (uuid "83df32a9-e416-44b3-a6f8-5a7275da5786" 'ext4))
           (type "ext4"))
         %base-file-systems))
