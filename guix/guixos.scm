;; OBSERVABILITY SERVICES (grafana, prometheus, blackbox-exporter):
;;   Added from gocix channel (fishinthecalculator/gocix), adapted to use oci-service-type.
;;   Services: docker-grafana (port 3000), docker-prometheus (ports 9000/9090), docker-blackbox-exporter (port 9115).
;;   TODO: Check if they start correctly after reboot — verify with `herd status` and `docker ps`.
;; GUIX-RELATED PACKAGES: guix-modules, gwl, bffe, guix-data-service, hpcguix-web, guix-build-coordinator already installed
;; CUIRASS CI: Uncomment service in root.scm and configure specs in ci/cuirass.scm
;; Add mcron jobs: (service mcron-service-type (mcron-configuration (jobs (list ...))))
;; OLLAMA SERVICE NEEDS WORK/ACTIVATION !!

(add-to-load-path "/home/aoeu/.config/guix/Operating-System")
(add-to-load-path "/home/aoeu/.config/guix/Operating-System/core-system/user-space/root/encryption/sops/modules")

(use-modules (core-system core-system))
;;(use-modules (systems containers containers))
;; ADD DOCKER WITH IMPURITIVE FS !! 

 ;; (operating-system
 ;;  (inherit os)
 ;;  (services (append all-container-services
 ;;                    (operating-system-user-services os))))
os
