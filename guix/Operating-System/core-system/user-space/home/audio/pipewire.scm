(define-module (core-system user-space home audio pipewire)
  #:use-module (gnu home services)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services desktop)
  #:use-module (gnu packages linux)
  #:export (home-pipewire-service home-dbus-service))

(define-public home-dbus-service
  (service home-dbus-service-type))

(define-public home-pipewire-service
  (service home-pipewire-service-type
           (home-pipewire-configuration
             (pipewire (@ (gnu packages linux) pipewire))
             (wireplumber (@ (gnu packages linux) wireplumber))
             (enable-pulseaudio? #t))))