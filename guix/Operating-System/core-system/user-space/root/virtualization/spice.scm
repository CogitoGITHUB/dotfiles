(define-module (core-system user-space root virtualization spice)
  #:use-module (guix packages)
  #:use-module (gnu packages spice)
  #:export (spice spice-gtk spice-vdagent))

(define-public spice
  (@@ (gnu packages spice) spice))

(define-public spice-gtk
  (@@ (gnu packages spice) spice-gtk))

(define-public spice-vdagent
  (@@ (gnu packages spice) spice-vdagent))
