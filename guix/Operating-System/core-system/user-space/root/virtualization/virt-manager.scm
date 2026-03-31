(define-module (core-system user-space root virtualization virt-manager)
  #:use-module (guix packages)
  #:use-module (gnu packages virtualization)
  #:export (virt-manager))

(define-public virt-manager
  (@@ (gnu packages virtualization) virt-manager))
