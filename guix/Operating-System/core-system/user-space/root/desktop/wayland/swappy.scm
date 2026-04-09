(define-module (core-system user-space root desktop wayland swappy)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (swappy))

(define-public swappy
  (package
    (name "swappy")
    (version "1.8.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/jtheoof/swappy")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0drihlsc193dzffnllpjwhq5n6j7m5pix1wxgnkgp4x3nvmvkxxc"))))
    (build-system meson-build-system)
    (inputs (list gtk+ libnotify))
    (native-inputs (list pkg-config glib))
    (home-page "https://github.com/jtheoof/swappy")
    (synopsis "Wayland screenshot utility")
    (description "Swappy is a Wayland screenshot utility.")
    (license license:gpl3+)))
