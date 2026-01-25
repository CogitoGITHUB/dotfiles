(use-modules (gnu)
             (gnu services))
(use-service-modules cups desktop networking ssh xorg nix)

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Bucharest")
  (keyboard-layout (keyboard-layout "us" "dvp"))
  (host-name "Master-Puppeet")

  (users (cons* (user-account
                  (name "aoeu")
                  (comment "Aoeu")
                  (group "users")
                  (home-directory "/home/aoeu")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

 
  (packages (append (list (specification->package "nss-certs")
                          (specification->package "nix"))
                    %base-packages))

  (services
   (append (list (service gnome-desktop-service-type)
                 (service openssh-service-type)
                 (service nix-service-type)
                 (service tor-service-type)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout))))
           %desktop-services))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))

  (swap-devices (list (swap-space
                        (target (uuid
                                 "c7d315aa-050e-433b-9752-89e4f9132d0d")))))

  
  (file-systems (cons* (file-system
                         (mount-point "/home")
                         (device (uuid
                                  "f70aba2c-d1ac-49bd-8f5c-c96a9b6771fc"
                                  'btrfs))
                         (type "btrfs"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "038C-9ECD"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid
                                  "6f2d422c-9168-4b3f-b7c2-e126d0a9cc3c"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
