(define-module (core-system user-space root editors emacs-packages emacs-monkeytype)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (core-system user-space root editors emacs-packages quick-peek)
  #:use-module (core-system user-space root editors emacs-packages scrollable-quick-peek)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-monkeytype))

(define-public emacs-monkeytype
  (package
    (name "emacs-monkeytype")
    (version "0.1.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/jpablobr/emacs-monkeytype")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0fgnfslhg10q96lyxfnpa7s8dvw5gjlll7p6qji2jfz3kncwhf5l"))))
    (build-system emacs-build-system)
    (inputs (list emacs-quick-peek emacs-scrollable-quick-peek))
    (propagated-inputs (list emacs-quick-peek emacs-scrollable-quick-peek))
    (synopsis "Typing game/tutor for Emacs inspired by monkeytype.com")
    (description "A typing game/tutor for Emacs inspired by monkeytype.com. Features WPM tracking, error highlighting, mistyped word practice, and customizable faces.")
    (home-page "https://github.com/jpablobr/emacs-monkeytype")
    (license license:gpl3+)))
