;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders virtualization)
  #:use-module (core-system user-space root virtualization qemu)
  #:use-module (core-system user-space root virtualization libvirt)
  #:use-module (core-system user-space root virtualization virt-manager)
  #:use-module (core-system user-space root virtualization virt-viewer)
  #:use-module (core-system user-space root virtualization spice)
  #:re-export (qemu libvirt virt-manager virt-viewer spice spice-gtk spice-vdagent)
  #:export (root-virtualization-packages))

(define-public root-virtualization-packages
  (list qemu libvirt virt-manager virt-viewer spice spice-gtk spice-vdagent))
