(define-module (core-system user-space root audio pipewire)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (pipewire wireplumber))

(define-public pipewire
  (package
    (name "pipewire")
    (version "1.6.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.freedesktop.org/pipewire/pipewire")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "01jvq9ck8dhkbmw21jw0frgbgvzwfq1dxkvl3zynrj179kpm4v9w"))))
    (build-system meson-build-system)
    (home-page "https://pipewire.org/")
    (synopsis "Server and user space API to deal with multimedia pipelines")
    (description "PipeWire is a project that aims to greatly improve handling of audio and video under Linux.")
    (license license:lgpl2.0+)))

(define-public wireplumber
  (package
    (name "wireplumber")
    (version "0.5.12")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.freedesktop.org/pipewire/wireplumber.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1dljz669ywy1lvvn0jh14ymynmbii45q5vay71zajpcg31249dyw"))))
    (build-system meson-build-system)
    (home-page "https://gitlab.freedesktop.org/pipewire/wireplumber")
    (synopsis "Session/policy manager implementation for PipeWire")
    (description "WirePlumber is a modular session/policy manager for PipeWire.")
    (license license:lgpl2.0+)))
