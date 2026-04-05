(define-module (core-system kernel-space kernel-space)
#:use-module (core-system kernel-space linux)
#:use-module (core-system kernel-space keyboard)
#:use-module (core-system kernel-space bootloader)
#:use-module (core-system kernel-space filesystem)
#:use-module (core-system kernel-space hostname)
#:use-module (core-system kernel-space locale)
#:use-module (core-system kernel-space elogind)
#:use-module (core-system kernel-space udev)
#:use-module (core-system kernel-space kmod)
#:re-export (kernel kernel-arguments kernel-modules kernel-initrd kernel-firmware
  keyboard-layout system-bootloader-configuration file-systems host-name
  system-locale system-timezone elogind-service udev-rules udev-service-type
  udev-configuration uinput-group-service)
#:export (kernel-system-services kernel-system-packages))

(define kernel-system-services
  (list elogind-service uinput-group-service kernel-modules))

(define kernel-system-packages kernel-firmware)