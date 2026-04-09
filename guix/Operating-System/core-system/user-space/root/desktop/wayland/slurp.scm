(define-module (core-system user-space root desktop wayland slurp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages man)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (slurp))

(define-public slurp
  (package
    (name "slurp")
    (version "1.5.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/emersion/slurp")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0wlml42c3shma50bsvqzll7p3zn251jaf0jm59q2idks8gg1zkyq"))))
    (build-system meson-build-system)
    (inputs (list cairo pixman libxkbcommon wayland))
    (native-inputs (list pkg-config scdoc))
    (home-page "https://github.com/emersion/slurp")
    (synopsis "Select a region in a Wayland compositor")
    (description "Slurp is a tool to select a region in a Wayland compositor.")
    (license license:expat)))