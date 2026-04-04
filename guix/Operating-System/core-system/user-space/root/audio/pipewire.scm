(define-module (core-system user-space root audio pipewire)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:export (pipewire-service wireplumber-service pipewire wireplumber))

(define-public pipewire (@@ (gnu packages linux) pipewire))
(define-public wireplumber (@@ (gnu packages linux) wireplumber))

(define-public pipewire-service
  (simple-service 'pipewire-system
                  shepherd-root-service-type
                  (list (shepherd-service
                          (provision '(pipewire))
                          (requirement '(user-processes dbus-system))
                          (start #~(begin
                                     (use-modules (srfi srfi-1) (srfi srfi-26))
                                     (make-forkexec-constructor
                                      (list #$(file-append (@@ (gnu packages linux) pipewire)
                                                           "/bin/pipewire")
                                            "/etc/pipewire/pipewire.conf")
                                      #:user "root"
                                      #:log-file "/var/log/pipewire.log")))
                          (stop #~(begin
                                    (use-modules (srfi srfi-1) (srfi srfi-26))
                                    (make-kill-destructor)))
                          (respawn? #t)))))

(define-public wireplumber-service
  (simple-service 'wireplumber-system
                  shepherd-root-service-type
                  (list (shepherd-service
                          (provision '(wireplumber))
                          (requirement '(pipewire))
                          (start #~(begin
                                     (use-modules (srfi srfi-1) (srfi srfi-26))
                                     (make-forkexec-constructor
                                      (list #$(file-append (@@ (gnu packages linux) wireplumber)
                                                           "/bin/wireplumber"))
                                      #:user "root"
                                      #:log-file "/var/log/wireplumber.log")))
                          (stop #~(begin
                                    (use-modules (srfi srfi-1) (srfi srfi-26))
                                    (make-kill-destructor)))
                          (respawn? #t)))))
