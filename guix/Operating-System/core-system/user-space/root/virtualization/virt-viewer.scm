(define-module (core-system user-space root virtualization virt-viewer)
  #:use-module (guix packages)
  #:use-module (gnu packages spice)
  #:export (virt-viewer))

(define-public virt-viewer
  (@@ (gnu packages spice) virt-viewer))
