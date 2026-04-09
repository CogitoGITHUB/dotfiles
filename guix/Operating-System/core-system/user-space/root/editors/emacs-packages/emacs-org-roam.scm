(define-module (core-system user-space root editors emacs-packages emacs-org-roam)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages emacs-build)
  #:use-module (gnu packages emacs-xyz)
  #:export (emacs-org-roam))

(define-public emacs-org-roam
  (package
    (name "emacs-org-roam")
    (version "2.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/org-roam/org-roam")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0cl0f50din00hj541iskl5mxr8ijaf5pnpy6z7zvsam8l4gj8f73"))))
    (build-system emacs-build-system)
    (arguments '(#:tests? #f))
    (propagated-inputs (list emacs-dash emacs-emacsql emacs-magit))
    (home-page "https://github.com/org-roam/org-roam/")
    (synopsis "Non-hierarchical note-taking with Org mode")
    (description "Emacs Org Roam is a solution for taking non-hierarchical notes with Org mode.")
    (license license:gpl3+)))
