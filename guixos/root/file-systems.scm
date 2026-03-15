;; File Systems and Swap Configuration

(use-modules (gnu system file-systems))

(define literativeos-file-systems
  (cons* (file-system
            (mount-point "/boot/efi")
            (device (uuid "84F3-3015" 'fat32))
            (type "vfat"))
          (file-system
            (mount-point "/")
            (device (uuid "a583c20c-b2c2-4cfe-af38-7d2ffff30926" 'ext4))
            (type "ext4"))
          %base-file-systems))

(define literativeos-swap-devices
  (list))
