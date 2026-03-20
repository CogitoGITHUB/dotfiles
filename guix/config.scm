;; LiterativeOS - Modular System Configuration
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

(use-modules (gnu)
             (gnu services networking)
             (gnu packages linux)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages terminals)

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
             (gnu packages curl)
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
             (guix packages)
             (guix licenses)
             (guix download)
             (guix build-system trivial)
             (guix build-system copy)
             (guix build-system go)
             (guix build-system gnu)
             (guix records)
             (guix gexp)
             (guix utils)
             (gnu packages elf)
             (ice-9 match))

;; Kernel config
(load (string-append %config-dir "/kernel/kernel.scm"))
(load (string-append %config-dir "/kernel/keyboard.scm"))
(load (string-append %config-dir "/kernel/bootloader.scm"))
(load (string-append %config-dir "/kernel/filesystem.scm"))
(load (string-append %config-dir "/kernel/swap.scm"))
(load (string-append %config-dir "/kernel/hostname.scm"))
(load (string-append %config-dir "/kernel/locale.scm"))
(load (string-append %config-dir "/kernel/elogind.scm"))

;; Home packages with services (load BEFORE greetd aggregation)
(load (string-append %config-dir "/home/packages/utils/keyd.scm"))
(load (string-append %config-dir "/home/packages/utils/kanata.scm"))
(load (string-append %config-dir "/home/packages/utils/tailscale.scm"))
(load (string-append %config-dir "/home/packages/desktop/hyprland.scm"))

;; Root config
(load (string-append %config-dir "/root/packages.scm"))
(load (string-append %config-dir "/root/openssh.scm"))

;; Root services (greetd has the services aggregation)
(load (string-append %config-dir "/kernel/udev.scm"))
(load (string-append %config-dir "/home/packages/desktop/greetd.scm"))

;; Home packages (without system services)
(load (string-append %config-dir "/home/packages/shell/nushell.scm"))
(load (string-append %config-dir "/home/packages/shell/starship.scm"))
(load (string-append %config-dir "/home/packages/shell/atuin.scm"))
(load (string-append %config-dir "/home/packages/shell/carapace.scm"))
(load (string-append %config-dir "/home/packages/shell/zoxide.scm"))
(load (string-append %config-dir "/home/packages/shell/fzf.scm"))
(load (string-append %config-dir "/home/packages/terminal/wezterm.scm"))
(load (string-append %config-dir "/home/packages/terminal/zellij.scm"))
(load (string-append %config-dir "/home/packages/desktop/hypridle.scm"))
(load (string-append %config-dir "/home/packages/desktop/hyprlock.scm"))
(load (string-append %config-dir "/home/packages/desktop/hyprpaper.scm"))
(load (string-append %config-dir "/home/packages/desktop/hyprsunset.scm"))
(load (string-append %config-dir "/home/packages/desktop/grimblast.scm"))
(load (string-append %config-dir "/home/packages/desktop/quickshell.scm"))
(load (string-append %config-dir "/home/packages/desktop/xdg-desktop-portal-hyprland.scm"))
(load (string-append %config-dir "/home/packages/editors/emacs.scm"))
(load (string-append %config-dir "/home/packages/editors/neovim.scm"))
(load (string-append %config-dir "/home/packages/dev/opencode.scm"))
(load (string-append %config-dir "/home/packages/utils/cage.scm"))
(load (string-append %config-dir "/home/packages/utils/gzip.scm"))
(load (string-append %config-dir "/home/packages/utils/bzip2.scm"))
(load (string-append %config-dir "/home/packages/utils/xz.scm"))
(load (string-append %config-dir "/home/packages/utils/findutils.scm"))
(load (string-append %config-dir "/home/packages/version-control/git.scm"))
(load (string-append %config-dir "/home/packages/version-control/gh.scm"))
(load (string-append %config-dir "/home/packages/version-control/lazygit.scm"))

(load (string-append %config-dir "/home/users.scm"))

(load (string-append %config-dir "/home/packages.scm"))

(define %literativeos-packages
  (append literativeos-home-packages
           literativeos-system-packages))

(operating-system
  (locale literativeos-locale)
  (timezone literativeos-timezone)
  (keyboard-layout literativeos-keyboard-layout)
  (host-name literativeos-host-name)
  (sudoers-file literativeos-sudoers-file)
  (setuid-programs literativeos-setuid-programs)

  (kernel literativeos-kernel)
  (firmware '())

  (packages %literativeos-packages)

  (users literativeos-users)

  (services literativeos-services)

  (bootloader literativeos-bootloader-configuration)

  (swap-devices literativeos-swap-devices)

  (file-systems literativeos-file-systems))
