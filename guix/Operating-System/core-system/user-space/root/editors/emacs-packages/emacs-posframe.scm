(define-module (core-system user-space root editors emacs-packages emacs-posframe)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-posframe))

(define-public emacs-posframe
  (package
    (name "emacs-posframe")
    (version "1.5.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://elpa.gnu.org/packages/"
                           "posframe-" version ".tar"))
       (sha256
        (base32 "1g1pcf83w4fv299ykvx7b93kxkc58fkr6yk39sxny5g16d4gl80g"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/tumashu/posframe")
    (synopsis "Pop a posframe (a child frame) at point")
    (description "Posframe can pop a posframe at point. A posframe is a child frame displayed within its root window's buffer.")
    (license license:gpl3+)))
