;; LiterativeOS - System Configuration
;;
;; REBUILD/RECONFIGURE INSTRUCTIONS:
;; --------------------------------
;; Once the system has working sudo (setuid-programs configured), you can:
;;
;;   guix system reconfigure ~/.config/guix/config.scm
;;
;; This will prompt for sudo password (NOPASSWD is configured for wheel group).
;;
;; If you ever break sudo again, use 'guix system build' to test config:
;;   guix system build ~/.config/guix/config.scm
;; This builds without activating - safe to test changes.
;;
;; The setuid-programs and sudoers-file fields are REQUIRED for passwordless sudo.
;; DO NOT remove them unless you have another way to get root access.

(define %config-dir "/home/aoeu/.config/guix")
(set! %load-path (cons %config-dir %load-path))

(use-modules (gnu)
              (gnu services networking)
              (gnu packages linux)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages terminals)
             (gnu packages version-control)
             (gnu packages admin)
             (gnu packages nss)
             (gnu packages wm)
             (gnu packages freedesktop)
             (gnu packages xdisorg)
             (gnu packages rust-apps)
             (gnu packages emacs)
             (gnu packages vim)
             (gnu packages shellutils)
             (gnu packages compression)
             (gnu packages base)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu system)
             (gnu system shadow)
             (gnu system setuid)
             (gnu services)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services shepherd)
             (gnu services xorg)
             (guix config)
             (guix packages))

(load (string-append %config-dir "/modules/opencode.scm"))
(load (string-append %config-dir "/modules/gh.scm"))
(load (string-append %config-dir "/modules/tailscale.scm"))
(load (string-append %config-dir "/modules/zellij.scm"))
(load (string-append %config-dir "/modules/fzf.scm"))
(load (string-append %config-dir "/modules/wezterm.scm"))
(load (string-append %config-dir "/modules/zoxide.scm"))
(load (string-append %config-dir "/modules/nushell.scm"))
(load (string-append %config-dir "/modules/starship.scm"))
(load (string-append %config-dir "/modules/desktop-env.scm"))
(load (string-append %config-dir "/modules/keyboard.scm"))

(define %literativeos-packages
  (list nushell fzf wezterm starship zellij zoxide tailscale tailscaled opencode gh git nss-certs sudo coreutils grep bash 
        hyprland hypridle hyprlock hyprpaper hyprsunset grimblast xdg-desktop-portal-hyprland greetd quickshell cage 
        emacs neovim
        kanata
        gzip bzip2 xz))

  (define (remove-gdm services)
    (filter (lambda (s)
              (not (memq (service-type-name (service-kind s))
                        '(gdm gdm-autologin gdm-launch-environment))))
            services))

  (define literativeos-root-services
    (remove-gdm
      (append (list (service tailscale-service-type)
                    (service hyprland-service-type)
                    (service kanata-service-type)
                    (service openssh-service-type)
                    (service greetd-service-type))
              %desktop-services)))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Bucharest")
  (keyboard-layout (keyboard-layout "us" "dvorak"))
  (host-name "aoeu")
  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

  ;; NOTE: This is REQUIRED for sudo to work - without it, sudo won't have
  ;; the setuid bit set and regular users can't run privileged commands.
  ;; DO NOT REMOVE THIS unless you have another way to get root access.
  ;; Also keep sudo in %literativeos-packages above.
  (setuid-programs (list (setuid-program
                          (program (file-append sudo "/bin/sudo")))))

  (kernel linux-libre)
  (firmware '())

  (packages %literativeos-packages)

  (users (list (user-account
                (name "root")
                (comment "System Administrator")
                (group "root")
                (home-directory "/root")
                (shell (file-append nushell "/bin/nu")))
               (user-account
                (name "aoeu")
                (comment "Aoeu")
                (group "users")
                (home-directory "/home/aoeu")
                (supplementary-groups '("wheel" "netdev" "audio" "video"))
                (shell (file-append nushell "/bin/nu")))))

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
