(define-module (core-system user-space root audio pulseaudio)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sound)
  #:use-module (gnu packages pulseaudio)
  #:use-module (guix gexp)
  #:export (pulseaudio-service pulseaudio))

(define-public pulseaudio
  (@@ (gnu packages pulseaudio) pulseaudio))

(define %pulseaudio-system.pa
  (plain-file "system.pa"
    "load-module module-device-restore
load-module module-stream-restore
load-module module-card-restore
load-module module-udev-detect
load-module module-native-protocol-unix auth-anonymous=1
load-module module-default-device-restore
load-module module-always-sink
load-module module-suspend-on-idle
load-module module-position-event-sounds
"))

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
                                           "--log-target=syslog"
                                           "--exit-idle-time=-1"
                                           (string-append "--file=" #$%pulseaudio-system.pa))
                                     #:user "root")))
                           (stop #~(begin
                                     (use-modules (srfi srfi-1) (srfi srfi-26))
                                     (make-kill-destructor)))
                          (respawn? #t)))))
