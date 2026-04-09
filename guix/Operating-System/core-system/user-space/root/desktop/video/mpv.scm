(define-module (core-system user-space root desktop video mpv)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages freedesktop)
  #:export (mpv))

(define-public mpv
  (package
    (name "mpv")
    (version "0.41.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mpv-player/mpv")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18l25s12g4sr0p3y6hk3cqa5rr5jykbdfhaqz4wyrvs8hy6b5xhk"))))
    (build-system meson-build-system)
    (arguments '(#:tests? #f))
    (inputs
     (list ffmpeg libass sdl2 lua pulseaudio wayland))
    (home-page "https://mpv.io")
    (synopsis "General-purpose video player")
    (description "mpv is a general-purpose video player, audio player, and subtitle renderer.")
    (license license:gpl2+)))