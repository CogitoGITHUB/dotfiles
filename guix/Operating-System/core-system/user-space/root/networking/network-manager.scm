(define-module (core-system user-space root networking network-manager)
  #:use-module ((gnu packages gnome) #:prefix gnome:)
  #:export (network-manager))

(define-public network-manager gnome:network-manager)
