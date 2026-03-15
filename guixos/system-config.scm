;; LiterativeOS - System Configuration
;; Uses system Guix 1.5.0 (base) + local config

(define %config-dir "/home/aoeu/.config/guix")
(set! %load-path (cons %config-dir %load-path))
(set! %load-path (cons (string-append %config-dir "/root") %load-path))
(set! %load-path (cons (string-append %config-dir "/root/vpn") %load-path))
(set! %load-path (cons (string-append %config-dir "/root/shells") %load-path))
(set! %load-path (cons (string-append %config-dir "/home") %load-path))

(use-modules (gnu)
             (gnu packages linux)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages nushell)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu system)
             (gnu system shadow)
             (gnu services)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services shepherd)
             (gnu services base)
             (guix config))



;; Load local config files
(load (string-append %config-dir "/root/file-systems.scm"))
(load (string-append %config-dir "/root/users.scm"))
(load (string-append %config-dir "/root/locale-timezone.scm"))
(load (string-append %config-dir "/root/packages-services.scm"))

;; Load home config
(load (string-append %config-dir "/home/packages-services.scm"))
(load (string-append %config-dir "/home/settings.scm"))

;; Define the LiterativeOS system
(operating-system
  (locale literativeos-locale)
  (timezone literativeos-timezone)
  (keyboard-layout literativeos-keyboard-layout)
  (host-name "aoeu")
  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))
  
  ;; Kernel configuration
  (kernel linux-libre)
  (firmware '())
  
  ;; Packages (root-level system packages)
  (packages literativeos-root-packages)
  
  ;; Users
  (users literativeos-users)
  
  ;; Services
  (services literativeos-root-services)
  
  ;; Bootloader
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (keyboard-layout literativeos-keyboard-layout)))
  
  ;; Swap devices
  (swap-devices literativeos-swap-devices)
  
  ;; File systems
  (file-systems literativeos-file-systems))
