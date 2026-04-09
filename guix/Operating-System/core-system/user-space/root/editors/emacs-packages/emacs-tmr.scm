(define-module (core-system user-space root editors emacs-packages emacs-tmr)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages video)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages libcanberra)
  #:export (emacs-tmr))

(define-public emacs-tmr
  (package
    (name "emacs-tmr")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/protesilaos/tmr")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0jv55l11fljfswv0flx3ylkh2x4zihq3n9w0lyjpnsf6wlq9cff3"))))
    (build-system emacs-build-system)
    (arguments '(#:tests? #f))
    (inputs (list ffmpeg sound-theme-freedesktop))
    (home-page "https://protesilaos.com/emacs/tmr/")
    (synopsis "Set timers using a convenient notation")
    (description "TMR is an Emacs package that provides facilities for setting timers using a convenient notation.")
    (license license:gpl3+)))
