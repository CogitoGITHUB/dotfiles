(define-module (core-system user-space root desktop qutebrowser)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system pyproject)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages)
  #:export (qutebrowser))

(define-public qutebrowser
  (package
    (name "qutebrowser")
    (version "3.6.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/qutebrowser/qutebrowser")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "19in8g80hhxr1mhi3gfscm3w6zvgfliws87zcxpzqm056bj9fanr"))))
    (build-system pyproject-build-system)
    (inputs (list python-pyqt python-pyqtwebengine python-jinja2 python-pyyaml))
    (native-inputs (list python-setuptools python-wheel))
    (home-page "https://qutebrowser.org/")
    (synopsis "Keyboard-driven Qt-based web browser")
    (description "qutebrowser is a keyboard-driven browser based on Qt.")
    (license license:gpl3+)))
