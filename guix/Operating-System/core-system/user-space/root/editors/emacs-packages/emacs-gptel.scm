(define-module (core-system user-space root editors emacs-packages emacs-gptel)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs-build)
  #:export (emacs-gptel))

(define-public emacs-gptel
  (package
    (name "emacs-gptel")
    (version "0.9.9.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/karthink/gptel")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1ffh2mwy9znjd0v9mh065lv122xg4nlnkbxwjfrsaqn1j1q2xc0c"))))
    (build-system emacs-build-system)
    (arguments '(#:tests? #f))
    (inputs (list curl))
    (propagated-inputs (list emacs-compat emacs-transient))
    (home-page "https://github.com/karthink/gptel")
    (synopsis "GPTel is a simple ChatGPT client for Emacs")
    (description "GPTel is a simple ChatGPT asynchronous client for Emacs with no external dependencies.")
    (license license:gpl3+)))
