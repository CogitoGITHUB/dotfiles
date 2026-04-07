(define-module (core-system user-space root loaders audio)
#:use-module (core-system user-space root audio alsa)
#:use-module (core-system user-space root audio pipewire)
#:use-module (core-system user-space root audio wiremix)
#:use-module (core-system user-space root audio music mpd)
#:use-module (core-system user-space root audio music rmpc)
#:use-module (core-system user-space root audio music cava)
#:re-export (rmpc mpd-service cava pipewire wireplumber
  alsa-utils alsa-service wiremix)
#:export (root-audio-packages root-audio-services))

(define-public root-audio-packages
  (list rmpc cava pipewire wireplumber alsa-utils wiremix))

(define-public root-audio-services (list alsa-service mpd-service))
