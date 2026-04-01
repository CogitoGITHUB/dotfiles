(define-module (core-system user-space root loaders audio)
#:use-module (core-system user-space root audio alsa)
#:use-module (core-system user-space root audio pulseaudio)
#:use-module (core-system user-space root audio pipewire)
#:use-module (core-system user-space root audio music mpd)
#:use-module (core-system user-space root audio music rmpc)
#:use-module (core-system user-space root audio music cava)
#:use-module (gnu services audio)
#:re-export (rmpc mpd-service cava pipewire wireplumber
  pulseaudio-service pulseaudio alsa-utils alsa-service)
#:export (root-audio-packages root-audio-services))

(define-public root-audio-packages
  (list rmpc cava pipewire wireplumber pulseaudio alsa-utils))

(define-public root-audio-services
  (list alsa-service pulseaudio-service mpd-service))
