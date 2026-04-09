(define-module (core-system user-space root shell power upower)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome)
  #:export (upower))

(define-public upower
  (package
    (name "upower")
    (version "1.90.10")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.freedesktop.org/upower/upower")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0vscs2n1qdbylnz37janvk0241g3ww3xcsk9402zn9sivnvl1jfk"))))
    (build-system meson-build-system)
    (arguments '(#:tests? #f))
    (inputs (list dbus glib libgudev))
    (home-page "https://upower.freedesktop.org/")
    (synopsis "System power management service")
    (description "UPower is a system daemon for managing power devices.")
    (license license:gpl2+)))
