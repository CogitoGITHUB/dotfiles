(use-modules (gnu))
(use-service-modules cups desktop networking ssh xorg)

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Bucharest")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "aoeu")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "aoeu")
                  (comment "Aoeu")
                  (group "users")
                  (home-directory "/home/aoeu")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "nss-certs"))
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list (service gnome-desktop-service-type)

                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service tor-service-type)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout))))

           ;; This is the default list of services we
           ;; are appending to.
           %desktop-services))
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "ef77c03d-26bb-46ec-aeee-9803bd01dc64")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "038C-9ECD"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid
                                  "93b882f7-8a48-4205-90c9-a83a050718bd"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
