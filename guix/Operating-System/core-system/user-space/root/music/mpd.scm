(define-module (core-system user-space root music mpd)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu services audio)
  #:use-module (gnu system accounts)
  #:use-module (core-system user-space root users users)
  #:export (mpd-service))

(define mpd-service
  (service mpd-service-type
           (mpd-configuration
             (user (car users))
             (music-directory "/home/aoeu/Music")
             (playlist-directory "/home/aoeu/Music/playlists")
             (auto-update? #t)
             (outputs
              (list (mpd-output
                      (name "my_fifo")
                      (type "fifo")
                      (enabled? #t)
                      (extra-options
                       `((path . "/tmp/mpd.fifo")
                         (format . "44100:16:2"))))
                    (mpd-output
                      (name "pulse")
                      (type "pulse")
                      (mixer-type "software")
                      (enabled? #t)
                      (extra-options
                       `((server . "/var/run/pulse/native")))))))))
