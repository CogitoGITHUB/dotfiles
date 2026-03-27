(define-module (core-system user-space root root)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu services docker)
  #:use-module (core-system user-space root users users)
  #:use-module (core-system user-space root core)
  #:use-module (core-system user-space root networking)
  #:use-module (core-system user-space root programming-languages)
  #:use-module (core-system user-space root editors)
  #:use-module (core-system user-space root shell)
  #:use-module (core-system user-space root containers)
  #:use-module (core-system user-space root keyboard)
  #:use-module (core-system user-space root terminal)
  #:use-module (core-system user-space root desktop)
  #:use-module (core-system user-space root ai)
  #:use-module (core-system user-space root custom-guix)
  #:re-export (users sudoers-file setuid-programs)
  #:export (root-system-packages root-system-services))

;; Packages
(define-public root-system-packages
  (append root-core-packages
          root-networking-packages
          root-programming-languages-packages
          root-editors-packages
          root-shell-packages
          root-containers-packages
          root-keyboard-packages
          root-terminal-packages
          root-desktop-packages
          root-ai-packages))

;; Services
(define-public root-system-services
  (append
   (list
    (service dhcpcd-service-type)
    (service openssh-service-type))
   root-networking-services
   root-containers-services
   %base-services))
