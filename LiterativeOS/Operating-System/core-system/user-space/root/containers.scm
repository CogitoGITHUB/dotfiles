(define-module (core-system user-space root containers)
  #:use-module (core-system user-space root containers containers)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:re-export (docker lazydocker)
  #:export (root-containers-packages root-containers-services))

(define-public root-containers-packages
  (list docker lazydocker))

(define-public root-containers-services
  (list (service containerd-service-type)
        (service docker-service-type)))