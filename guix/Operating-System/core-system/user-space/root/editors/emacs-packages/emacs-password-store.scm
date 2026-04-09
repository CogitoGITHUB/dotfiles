(define-module (core-system user-space root editors emacs-packages emacs-password-store)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages emacs-xyz)
  #:export (emacs-password-store emacs-pass))

(define-public emacs-password-store
  (package
    (name "emacs-password-store")
    (version "2.3.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.zx2c4.com/password-store")
             (commit "b5e965a838bb68c1227caa2cdd874ba496f10149")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hb5zm7hdp7vmqk39a9s1iyncx4swmwfq30dnnzkjk2y08lnb7ac"))))
    (build-system emacs-build-system)
    (inputs (list password-store))
    (propagated-inputs (list emacs-with-editor))
    (home-page "https://git.zx2c4.com/password-store/tree/contrib/emacs")
    (synopsis "Password store (pass) support for Emacs")
    (description "This package provides functions for working with pass (the standard Unix password manager).")
    (license license:gpl3+)))

(define-public emacs-pass
  emacs-password-store)
