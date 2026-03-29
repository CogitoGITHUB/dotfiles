(define-module (core-system user-space root loaders music)
  #:use-module (core-system user-space root music rmpc)
  #:use-module (core-system user-space root music mpd)
  #:re-export (rmpc mpd-service)
  #:export (root-music-packages root-music-services))

(define root-music-packages
  (list rmpc))

(define root-music-services
  (list mpd-service))
