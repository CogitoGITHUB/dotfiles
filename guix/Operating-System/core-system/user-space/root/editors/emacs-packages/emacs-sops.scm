(define-module (core-system user-space root editors emacs-packages emacs-sops)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-sops))

(define-public emacs-sops
  (package
    (name "emacs-sops")
    (version "0.1.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/djgoku/sops")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0vi7jw7zqj04ikajnssa68v6npd43bvaiw2afck25wxa9hnaja7f"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/djgoku/sops")
    (synopsis "SOPS encrypt and decrypt without leaving the editor")
    (description "This package provides a minor mode for editing SOPS-encrypted files.")
    (license license:gpl3+)))
