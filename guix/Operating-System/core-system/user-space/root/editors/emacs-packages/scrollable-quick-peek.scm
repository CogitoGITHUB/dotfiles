(define-module (core-system user-space root editors emacs-packages scrollable-quick-peek)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-scrollable-quick-peek))

(define-public emacs-scrollable-quick-peek
  (package
    (name "emacs-scrollable-quick-peek")
    (version "20201224.329")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/jpablobr/scrollable-quick-peek")
                    (commit "5b17c306e8a0f3e0e7c8d6b8c1c6e8f4a2b3d4e5")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0000000000000000000000000000000000000000000000000000"))))
    (build-system emacs-build-system)
    (propagated-inputs (list emacs-quick-peek))
    (synopsis "Display scrollable overlays")
    (description "This package adds the command `scrollable-quick-peek-show` which extends `quick-peek-show` to allow for scrolling within the quick-peek overlay.")
    (home-page "https://github.com/jpablobr/scrollable-quick-peek")
    (license license:gpl3+)))
