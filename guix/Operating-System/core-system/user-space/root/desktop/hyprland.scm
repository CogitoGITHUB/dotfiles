(define-module (core-system user-space root desktop hyprland)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages pkg-config)
  #:export (hyprland))

(define-public hyprland
  (package
    (name "hyprland")
    (version "0.54.3")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/hyprwm/Hyprland"
                            "/releases/download/v" version
                            "/source-v" version ".tar.gz"))
        (sha256
          (base32 "1vk39k04x210zdlrszs465cwkbf6j3b3ddldk9gzffpjls8s281w"))))
    (build-system cmake-build-system)
    (arguments
      '(#:tests? #f
        #:configure-flags (list "-DNO_HYPRPM=True")))
    (inputs (list hyprlang hyprutils wayland wayland-protocols
                  libxkbcommon libinput-minimal mesa))
    (native-inputs (list pkg-config))
    (home-page "https://hypr.land/")
    (synopsis "Dynamic tiling Wayland compositor")
    (description "Hyprland is a dynamic tiling Wayland compositor.")
    (license license:bsd-3)))
