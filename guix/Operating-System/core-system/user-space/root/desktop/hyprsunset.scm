(define-module (core-system user-space root desktop hyprsunset)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:export (hyprsunset))

(define-public hyprsunset
  (package
    (name "hyprsunset")
    (version "0.3.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/hyprwm/hyprsunset")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1k2gzbin4k18n81a0jpj8gbfphnib6kz4bbhbyhygb4p607sfkk2"))))
    (build-system cmake-build-system)
    (arguments '(#:tests? #f))
    (inputs (list hyprlang hyprutils wayland))
    (native-inputs (list pkg-config))
    (home-page "https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/")
    (synopsis "Blue-light filter for Hyprland")
    (description "Blue-light filter and gamma control for Hyprland.")
    (license license:bsd-3)))
