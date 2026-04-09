(define-module (core-system user-space root editors emacs-packages geiser)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages scheme)
  #:use-module (gnu packages guile)
  #:export (emacs-geiser emacs-geiser-guile))

(define-public emacs-geiser
  (package
    (name "emacs-geiser")
    (version "0.32")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.com/emacs-geiser/geiser")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "09dqwxa2h471xcyk5zncxzaz19gf8d5r83yhi425blf2r1ir7b34"))))
    (build-system emacs-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://www.nongnu.org/geiser/")
    (synopsis "Collection of Emacs modes for Scheme hacking")
    (description "Geiser is a collection of Emacs major and minor modes that conspire with one or more Scheme implementations.")
    (license license:bsd-3)))

(define-public emacs-geiser-guile
  (package
    (inherit emacs-geiser)
    (name "emacs-geiser-guile")
    (propagated-inputs (list emacs-geiser guile-3.0))
    (synopsis "Guile support for Geiser")))
