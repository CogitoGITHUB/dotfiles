(define-module (core-system user-space root music mpd)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu services audio)
  #:use-module (core-system user-space root users users)
  #:export (mpd-service))

(define mpd-service
  (service mpd-service-type
           (mpd-configuration
             (music-directory "/home/aoeu/Music"))))
