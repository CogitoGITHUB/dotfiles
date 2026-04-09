(define-module (core-system user-space root editors emacs-packages emacs-multiple-cursors)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-multiple-cursors))

(define-public emacs-multiple-cursors
  (package
    (name "emacs-multiple-cursors")
    (version "1.5.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/magnars/multiple-cursors.el")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "01ccwbfrnc66ax4bngw1b6k9rzw0m85cm4s0wzk1gkdsc2z647jn"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/magnars/multiple-cursors.el")
    (synopsis "Multiple cursors for Emacs")
    (description "This package adds support to Emacs for editing text with multiple simultaneous cursors.")
    (license license:gpl3+)))
