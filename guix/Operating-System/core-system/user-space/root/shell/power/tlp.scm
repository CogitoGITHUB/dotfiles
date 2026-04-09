(define-module (core-system user-space root shell power tlp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages base)
  #:use-module (gnu packages haskell-apps)
  #:export (tlp))

(define-public tlp
  (package
    (name "tlp")
    (version "1.9.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/linrunner/TLP")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0msskz42yy0ddq6gqak0dsl77wsym24ly3bkpymfwl9dr3wzikv8"))))
    (build-system gnu-build-system)
    (native-inputs (list shellcheck))
    (inputs (list dbus ethtool eudev grep))
    (home-page "https://linrunner.de/tlp/")
    (synopsis "Linux Advanced Power Management")
    (description "TLP brings you the benefits of advanced power management without the need to understand every technical detail.")
    (license license:gpl2+)))
