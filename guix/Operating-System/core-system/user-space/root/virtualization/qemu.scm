(define-module (core-system user-space root virtualization qemu)
  #:use-module (guix packages)
  #:use-module (gnu packages virtualization)
  #:export (qemu))

(define-public qemu
  (@@ (gnu packages virtualization) qemu))
