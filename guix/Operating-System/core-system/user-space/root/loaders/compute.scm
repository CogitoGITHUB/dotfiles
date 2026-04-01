;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders compute)
  #:use-module (core-system user-space root compute virtualization qemu)
  #:use-module (core-system user-space root compute virtualization libvirt)
  #:use-module (core-system user-space root compute virtualization virt-manager)
  #:use-module (core-system user-space root compute virtualization virt-viewer)
  #:use-module (core-system user-space root compute virtualization spice)
  #:use-module (core-system user-space root compute orchestration ganeti)
  #:use-module (core-system user-space root compute orchestration ganeti-instance-guix)
  #:re-export (qemu libvirt virt-manager virt-viewer spice spice-gtk spice-vdagent ganeti ganeti-instance-guix)
  #:export (root-compute-packages))

(define-public root-compute-packages
  (list qemu libvirt virt-manager virt-viewer spice spice-gtk spice-vdagent ganeti ganeti-instance-guix))
