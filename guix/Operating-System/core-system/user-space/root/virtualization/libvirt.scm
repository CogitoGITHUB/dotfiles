(define-module (core-system user-space root virtualization libvirt)
  #:use-module (guix packages)
  #:use-module (gnu packages virtualization)
  #:export (libvirt))

(define-public libvirt
  (@@ (gnu packages virtualization) libvirt))
