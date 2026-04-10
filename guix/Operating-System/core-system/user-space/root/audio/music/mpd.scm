(define-module (core-system user-space root audio music mpd)
  #:use-module (gnu services)
  #:use-module (gnu services audio)
  #:use-module (gnu packages mpd)
  #:use-module (gnu system accounts)
  #:export (mpd mpd-service))

(define-public mpd (@ (gnu packages mpd) mpd))

(define-public mpd-service
  (service mpd-service-type
           (mpd-configuration
             (user "aoeu")
             (music-directory "/home/aoeu/Music")
             (playlist-directory "/home/aoeu/Music/playlists")
             (environment-variables
               (list "XDG_RUNTIME_DIR=/run/user/1000"
                     "PIPEWIRE_RUNTIME_DIR=/run/user/1000"))
             (outputs (list
                        (mpd-output
                          (name "PipeWire")
                          (type "pipewire"))
                        (mpd-output
                          (name "cava-fifo")
                          (type "fifo")
                          (extra-options
                            '((path . "/tmp/mpd.fifo")
                              (format . "44100:16:2")))))))))