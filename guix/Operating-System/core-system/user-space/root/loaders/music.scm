(define-module (core-system user-space root loaders music)
  #:use-module (core-system user-space root music rmpc)
  #:use-module (core-system user-space root music mpd)
  #:use-module (core-system user-space root music cava)
  #:use-module (core-system user-space root music pipewire)
  #:use-module (core-system user-space root music pulseaudio)
  #:use-module (core-system user-space root music alsa)
  #:use-module (gnu services audio)
  #:re-export (rmpc mpd-service cava pipewire wireplumber
               pulseaudio-service pulseaudio alsa-utils alsa-service)
  #:export (root-music-packages root-music-services))

(define-public root-music-packages
  (list rmpc cava pipewire wireplumber pulseaudio alsa-utils))
(define-public root-music-services
  (list alsa-service pulseaudio-service mpd-service))
