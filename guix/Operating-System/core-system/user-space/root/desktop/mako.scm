(define-module (core-system user-space root desktop mako)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages man)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages documentation)
  #:export (mako))

(define-public mako
  (package
    (name "mako")
    (version "1.10.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/emersion/mako")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0hv083k3gp1gl2gxi91f2xf21hcn33z68j6r5844hzi7g8wwmp9v"))))
    (build-system meson-build-system)
    (inputs (list basu cairo gdk-pixbuf pango wayland))
    (native-inputs (list pkg-config scdoc wayland-protocols))
    (home-page "https://wayland.emersion.fr/mako")
    (synopsis "Lightweight Wayland notification daemon")
    (description "Mako is a lightweight notification daemon for Wayland.")
    (license license:expat)))
