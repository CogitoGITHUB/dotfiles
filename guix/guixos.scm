;; grafana tui and n8n dont work need work !!
;; OBSERVABILITY SERVICES (grafana, prometheus, blackbox-exporter):
;;   Added from gocix channel (fishinthecalculator/gocix), adapted to use oci-service-type.
;;   Services: docker-grafana (port 3000), docker-prometheus (ports 9000/9090), docker-blackbox-exporter (port 9115).
;;   TODO: Check if they start correctly after reboot — verify with `herd status` and `docker ps`.
;; GUIX-RELATED PACKAGES: guix-modules, gwl, bffe, guix-data-service, hpcguix-web, guix-build-coordinator already installed
;; CUIRASS CI: Uncomment service in root.scm and configure specs in ci/cuirass.scm
;; Add mcron jobs: (service mcron-service-type (mcron-configuration (jobs (list ...))))
;; OLLAMA SERVICE NEEDS WORK/ACTIVATION !!

;; Add load paths BEFORE any module resolution
(add-to-load-path "/home/aoeu/.config/guix/Operating-System")
(add-to-load-path "/home/aoeu/.config/guix/Operating-System/core-system/user-space/root/security/sops/modules")

(define-module (guixos-user)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (gnu services guix)
  #:use-module (gnu packages password-utils)
  #:use-module (core-system kernel-space kernel-space)
  #:use-module (core-system user-space root users aoeu)
  #:use-module (core-system user-space root root)
  #:use-module (core-system user-space home home))

(define os
  (operating-system
    (host-name host-name)
    (timezone system-timezone)
    (locale system-locale)
    (kernel kernel)
    (kernel-arguments kernel-arguments)
    (initrd kernel-initrd)
    (firmware kernel-firmware)
    (keyboard-layout keyboard-layout)
    (bootloader system-bootloader-configuration)
    (file-systems file-systems)
    (users users)
    (groups groups)
    (sudoers-file sudoers-file)
    (setuid-programs setuid-programs)
    (packages root-system-packages)
    (services (append kernel-system-services
                      root-system-services
                      (list (service guix-home-service-type
                                     (list (list "aoeu" literative-home-environment))))))))

os
