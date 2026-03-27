(define-module (core-system user-space root custom-guix channel)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (guix channels)
  #:export (%custom-guix-channels
            %custom-guix-service))

(define-public %custom-guix-channels
  (list (channel
          (name 'guix)
          (url "https://git.guix.gnu.org/guix.git")
          (branch "master"))))

(define-public %custom-guix-service
  (service guix-service-type
           (guix-configuration
            (channels %custom-guix-channels))))
