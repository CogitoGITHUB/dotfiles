(define-module (core-system core-system)
  #:use-module (gnu system)
  #:use-module (gnu system accounts)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services guix)
  #:use-module (gnu home)
  #:use-module (srfi srfi-39)
  #:use-module (core-system kernel-space kernel-space)
  #:use-module (core-system user-space root root)
  #:use-module (core-system user-space home home)
  #:export (os))

(define-public os
  (operating-system
    (host-name host-name)
    (timezone system-timezone)
    (locale system-locale)
    (kernel kernel)
    (kernel-arguments kernel-arguments)
    (initrd kernel-initrd)
    (firmware kernel-firmware)
    (keyboard-layout keyboard-layout)
    (bootloader system-bootloader-configuration)
    (file-systems file-systems)
    (users users)
    (groups groups)
    (sudoers-file sudoers-file)
    (setuid-programs setuid-programs)
    (packages root-system-packages)
    (services (append kernel-system-services
                      root-system-services
                      (list (service guix-home-service-type
                                     (list (list "aoeu" literative-home-environment))))))))