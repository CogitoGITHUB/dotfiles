(define-module (systems containers devsecops)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (gnu packages version-control)
  #:use-module (gnu services docker)
  #:use-module (systems containers core-container)
  #:export (devsecops-os devsecops-service))

(define-public devsecops-os
  (operating-system
    (inherit container-os)
    (host-name "guixos-devsecops")
    (packages (append (list git)
                      (operating-system-packages container-os)))))

(define-public devsecops-service
  (service oci-container-service-type
           (list (oci-container-configuration
                   (image (oci-image
                            (repository "guixos-devsecops")
                            (tag "latest")
                            (value devsecops-os)))
                   (network "host")
                   (auto-start? #t)
                   (respawn? #t)))))
