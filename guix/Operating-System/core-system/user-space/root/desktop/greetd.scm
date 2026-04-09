(define-module (core-system user-space root desktop greetd)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages bash)
  #:export (greetd))

(define-public greetd
  (package
    (name "greetd")
    (version "0.10.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sr.ht/~kennylevinsen/greetd")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1j3c7skby9scsq6p1f6nacbiy9b26y1sswchdsp8p3vv7fgdh2wf"))))
    (build-system cargo-build-system)
    (arguments '(#:install-source? #f))
    (inputs (list bash linux-pam))
    (home-page "https://git.sr.ht/~kennylevinsen/greetd")
    (synopsis "Minimal and flexible login manager daemon")
    (description "greetd is a minimal and flexible login manager daemon that makes no assumptions about what you want to launch.")
    (license license:gpl3+)))
