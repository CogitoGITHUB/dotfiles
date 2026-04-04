(define-module (core-system user-space root editors emacs-packages notebook-mode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-notebook-mode))

(define-public emacs-notebook-mode
  (package
    (name "emacs-notebook-mode")
    (version "0.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/rougier/notebook-mode")
                    (commit "master")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1gjam8wdwdprgfc9354cgr2c0qm2sngw306k1dv08hda0ng3ms65"))))
    (build-system emacs-build-system)
    (propagated-inputs (list emacs-svg-tag-mode))
    (synopsis "GNU Emacs notebook mode")
    (description "Notebook mode for GNU Emacs, inspired by Jupyter notebooks. Provides an interactive computing environment within Emacs using org-mode.")
    (home-page "https://github.com/rougier/notebook-mode")
    (license license:gpl3+)))
