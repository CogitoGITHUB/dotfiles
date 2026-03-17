;; LiterativeOS - System Configuration

(define %config-dir "/home/aoeu/.config/guix")
(set! %load-path (cons %config-dir %load-path))

(use-modules (gnu)
             (gnu packages linux)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages nushell)
             (gnu packages terminals)
             (gnu packages version-control)
             (gnu packages admin)
             (gnu packages nss)
             (gnu packages wm)
             (gnu packages freedesktop)
             (gnu packages xdisorg)
             (gnu packages rust-apps)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu system)
             (gnu system shadow)
             (gnu services)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services shepherd)
             (gnu services base)
             (gnu services xorg)
             (guix config))

;; Load custom packages
(load (string-append %config-dir "/opencode.scm"))
(load (string-append %config-dir "/gh.scm"))
(load (string-append %config-dir "/tailscale.scm"))
(load (string-append %config-dir "/atuin.scm"))
(load (string-append %config-dir "/zellij.scm"))
(load (string-append %config-dir "/emacs/emacs.scm"))

(use-modules (shells atuin)
             (shells zellij)
             (tools opencode)
             (tools gh)
             (vpn tailscale))

(define %literativeos-packages
  (list nushell fzf wezterm atuin zellij zoxide tailscale tailscaled opencode gh git nss-certs sudo coreutils bash hyprland hypridle hyprlock hyprpaper hyprsunset grimblast xdg-desktop-portal-hyprland greetd quickshell cage emacs))

(define (hyprland-etc-service config)
  `(("wayland-sessions/hyprland.desktop"
     ,(plain-file "hyprland.desktop"
       "[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=WaylandSession
DesktopNames=Hyprland
"))))

(define hyprland-service-type
  (service-type (name 'hyprland)
                (extensions
                 (list (service-extension etc-service-type
                                          hyprland-etc-service)))
                (default-value #f)
                (description "Hyprland Wayland compositor service")))

(define literativeos-root-services
  (modify-services
    (append (list (service openssh-service-type)
                  (service tailscale-service-type)
                  (service hyprland-service-type))
            (delete gdm-service-type %desktop-services))
    (mingetty-service-type config =>
                           (mingetty-configuration
                            (inherit config)
                            (auto-login "aoeu")))))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Bucharest")
  (keyboard-layout (keyboard-layout "us" "dvorak"))
  (host-name "aoeu")
  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

  (kernel linux-libre)
  (firmware '())

  (packages %literativeos-packages)

  (users (cons* (user-account
                  (name "aoeu")
                  (comment "Aoeu")
                  (group "users")
                  (home-directory "/home/aoeu")
                  (shell (file-append nushell "/bin/nu"))
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  (services literativeos-root-services)

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (keyboard-layout keyboard-layout)))

  (swap-devices (list))

  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "84F3-3015" 'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid "83df32a9-e416-44b3-a6f8-5a7275da5786" 'ext4))
                         (type "ext4"))
                       %base-file-systems)))
