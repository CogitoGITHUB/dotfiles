(define-module (core-system user-space home loaders audio)
  #:use-module (core-system user-space home audio pipewire)
  #:re-export (home-pipewire-service home-dbus-service)
  #:export (home-audio-services))

(define-public home-audio-services
  (list home-dbus-service home-pipewire-service))