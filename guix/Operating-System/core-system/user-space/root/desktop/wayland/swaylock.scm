(define-module (core-system user-space root desktop wayland swaylock)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages man)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (swaylock))

(define-public swaylock
  (package
    (name "swaylock")
    (version "1.8.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/swaywm/swaylock")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "01zwlfpf3s8wd8gl2sjfch1z66mqx9n2plgbdang7plqc3r01474"))))
    (build-system meson-build-system)
    (inputs (list cairo gdk-pixbuf libxkbcommon linux-pam wayland))
    (native-inputs (list pkg-config scdoc wayland-protocols))
    (home-page "https://github.com/swaywm/swaylock")
    (synopsis "Screen locking utility for Wayland compositors")
    (description "Swaylock is a screen locking utility for Wayland compositors.")
    (license license:expat)))