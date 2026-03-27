(define-module (core-system user-space root loaders containers)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (core-system user-space root containers docker)
  #:use-module (core-system user-space root containers lazydocker)
  #:export (root-containers-packages root-containers-services))

(define-public root-containers-packages
  (list docker lazydocker))

(define-public root-containers-services
  (list (service containerd-service-type)
        (service docker-service-type)))