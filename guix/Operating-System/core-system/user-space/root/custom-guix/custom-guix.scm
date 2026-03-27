(define-module (core-system user-space root custom-guix)
  #:use-module (gnu services package-management)
  #:use-module (guix channels)
  #:export (custom-guix-service))

(define-public %custom-guix-channels
  (list (channel
          (name 'guix)
          (url "https://git.guix.gnu.org/guix.git")
          (commit "b0fa1dc"))))

(define-public custom-guix-service
  (guix-service-type
   (guix-configuration
    (channels %custom-guix-channels))))
