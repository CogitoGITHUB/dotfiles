(define-module (core-system user-space root loaders video)
  #:use-module (core-system user-space root desktop video ffmpeg)
  #:use-module (core-system user-space root desktop video kdenlive)
  #:use-module (core-system user-space root desktop video mlt)
  #:use-module (core-system user-space root desktop video opentimelineio)
  #:use-module (core-system user-space root desktop video gst-editing-services)
  #:use-module (core-system user-space root desktop video mpv)
  #:use-module (core-system user-space root desktop video obs)
  #:use-module (core-system user-space root desktop video xytz)
  #:re-export (ffmpeg kdenlive mlt opentimelineio gst-editing-services mpv obs xytz)
  #:export (root-desktop-video-packages))

(define-public root-desktop-video-packages
  (list ffmpeg kdenlive mlt opentimelineio gst-editing-services mpv obs xytz))
