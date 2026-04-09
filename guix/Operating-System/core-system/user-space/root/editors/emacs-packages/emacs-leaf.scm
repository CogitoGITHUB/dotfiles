(define-module (core-system user-space root editors emacs-packages emacs-leaf)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-leaf))

(define-public emacs-leaf
  (package
    (name "emacs-leaf")
    (version "4.5.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://elpa.gnu.org/packages/"
                           "leaf-" version ".tar"))
       (sha256
        (base32 "1rdbrf84ijapiqhq72gy8r5xgk54sf0jy31pgd3w4rl1wywh5cas"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/conao3/leaf.el")
    (synopsis "Simplify your init.el configuration, extended use-package")
    (description "This package provides macros that allows you to declaratively configure settings typical of an Elisp package.")
    (license license:agpl3+)))
