(define-module (core-system user-space root desktop wayland wlogout)
  #:use-module (guix packages)
  #:use-module (gnu packages man)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (wlogout))

(define-public wlogout
  (package
    (name "wlogout")
    (version "1.2.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ArtsyMacaw/wlogout")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0pzgpfnfzpkc6y14x4g5wv5ldm67vshcp893i4rszfx4kv5ikmpy"))))
    (build-system meson-build-system)
    (inputs (list gtk-layer-shell gtk+))
    (native-inputs (list pkg-config scdoc))
    (arguments '(#:tests? #f))
    (home-page "https://github.com/ArtsyMacaw/wlogout")
    (synopsis "Wayland logout menu")
    (description "Logout menu for Wayland compositors.")
    (license license:expat)))
