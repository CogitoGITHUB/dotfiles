(define-module (core-system user-space root shell system-monitor ncdu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages ncurses)
  #:export (ncdu))

(define-public ncdu
  (package
    (name "ncdu")
    (version "2.9.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://dev.yorhel.nl/download/ncdu-" version ".tar.gz"))
        (sha256
          (base32 "1jffh675rpm3rfl0qk2ja9z1x6a6f8ksq2scrbr6jrdn3hl3a4g9"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (inputs (list ncurses))
    (home-page "https://dev.yorhel.nl/ncdu/")
    (synopsis "Ncurses-based disk usage analyzer")
    (description "Ncdu is a disk usage analyzer with an ncurses interface.")
    (license license:bsd-2)))
