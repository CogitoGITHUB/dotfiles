(define-module (core-system user-space root desktop wayland grim)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages man)
  #:use-module (gnu packages image)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (grim))

(define-public grim
  (package
    (name "grim")
    (version "1.5.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.freedesktop.org/emersion/grim/")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1rabva3x203hbsnmad6zrvlpxadmxw1zmd42i3pjk05pnk73mym0"))))
    (build-system meson-build-system)
    (inputs (list pixman libpng libjpeg-turbo wayland))
    (native-inputs (list pkg-config scdoc))
    (home-page "https://gitlab.freedesktop.org/emersion/grim")
    (synopsis "Screenshot tool for Wayland")
    (description "Grim is a screenshot tool for Wayland compositors.")
    (license license:expat)))