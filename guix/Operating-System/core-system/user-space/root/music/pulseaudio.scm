(define-module (core-system user-space root music pulseaudio)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sound)
  #:use-module (gnu packages pulseaudio)
  #:use-module (guix gexp)
  #:export (pulseaudio-service pulseaudio))

(define-public pulseaudio
  (@@ (gnu packages pulseaudio) pulseaudio))

(define-public pulseaudio-service
  (simple-service 'pulseaudio-system
                  shepherd-root-service-type
                  (list (shepherd-service
                          (provision '(pulseaudio))
                          (requirement '(user-processes))
                           (start #~(begin
                                      (use-modules (srfi srfi-1) (srfi srfi-26))
                                      (make-forkexec-constructor
                                     (list #$(file-append (@@ (gnu packages pulseaudio) pulseaudio)
                                                          "/bin/pulseaudio")
                                           "--system"
                                           "--disallow-exit"
                                           "--log-target=syslog")
                                     #:user "root")))
                           (stop #~(begin
                                     (use-modules (srfi srfi-1) (srfi srfi-26))
                                     (make-kill-destructor)))
                          (respawn? #t)))))
