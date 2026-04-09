(define-module (core-system user-space root desktop hypridle)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:export (hypridle))

(define-public hypridle
  (package
    (name "hypridle")
    (version "0.1.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/hyprwm/hypridle")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "17h5zmiiq6njc0adkkdrxyhr89dz19z74j9lb0scd7n2g89mcd33"))))
    (build-system cmake-build-system)
    (arguments '(#:tests? #f))
    (inputs (list hyprlang hyprutils wayland sdbus-c++))
    (native-inputs (list pkg-config))
    (home-page "https://github.com/hyprwm/hypridle")
    (synopsis "Hyprland's idle daemon")
    (description "Hyprland idle daemon for screen locking and power management.")
    (license license:bsd-3)))
