(define-module (core-system user-space root desktop wayland wl-clipboard)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages man)
  #:export (wl-clipboard))

(define-public wl-clipboard
  (package
    (name "wl-clipboard")
    (version "2.2.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/bugaevc/wl-clipboard")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "09l6dv3qsqscbr98vxi4wg4rkx0wlhnsc40n21mx3ds6balmg105"))))
    (build-system meson-build-system)
    (inputs (list wayland))
    (native-inputs (list pkg-config scdoc))
    (home-page "https://github.com/bugaevc/wl-clipboard")
    (synopsis "Wayland clipboard utilities")
    (description "Clipboard utilities for Wayland.")
    (license license:gpl3+)))
