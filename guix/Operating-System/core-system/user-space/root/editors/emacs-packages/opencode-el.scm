(define-module (core-system user-space root editors emacs-packages opencode-el)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-opencode-el))

(define-public emacs-opencode-el
  (package
    (name "emacs-opencode-el")
    (version "0.0.1-1.3e3f9ff")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://codeberg.org/sczi/opencode.el/archive/"
              "3e3f9ff.tar.gz"))
        (sha256
         (base32 "1ffzx0lh6rbmzrzqqrn70gpjg2brq67cppvgpry1hg6h598gf6si"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-magit
           emacs-markdown-mode
           emacs-plz
           emacs-plz-media-type
            emacs-plz-event-source))
    (home-page "https://codeberg.org/sczi/opencode.el")
    (synopsis "Emacs interface to OpenCode")
    (description
     "opencode.el provides an Emacs interface to the OpenCode AI coding agent.
It enables interactive sessions with OpenCode through Emacs, allowing you to
leverage AI-powered code generation, refactoring, and analysis directly from
your editor.")
    (license license:gpl3+)))
