(define-module (systems containers core-container)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (core-system core-system)
  #:export (container-os container-service))

(define-public container-os
  (operating-system
    (inherit os)
    (host-name "guixos-container")))

(define-public container-service
  (service oci-container-service-type
           (list (oci-container-configuration
                   (image (oci-image
                            (repository "guixos")
                            (tag "latest")
                            (value container-os)))
                   (network "host")
                   (auto-start? #t)
                   (respawn? #t)))))
