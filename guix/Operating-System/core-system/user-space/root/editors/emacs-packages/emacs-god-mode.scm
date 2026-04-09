(define-module (core-system user-space root editors emacs-packages emacs-god-mode)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-god-mode))

(define-public emacs-god-mode
  (package
    (name "emacs-god-mode")
    (version "2.19.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/emacsorphanage/god-mode")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1b39lq1l7xa2i4l5ciry3pjaxgzs0xawadb5kbcfhqhd4xlgb04g"))))
    (build-system emacs-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://github.com/emacsorphanage/god-mode")
    (synopsis "Minor mode for entering commands without modifier keys")
    (description "This package provides a global minor mode for entering Emacs commands without modifier keys.")
    (license license:gpl3+)))
