(define-module (core-system user-space root shell fzf)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages tmux)
  #:export (fzf))

(define-public fzf
  (package
    (name "fzf")
    (version "0.67.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/junegunn/fzf")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1yia1i1dp9k8dpw88n98gpmvzirp4lck7h62rkx39nhwr4mg5a1z"))))
    (build-system go-build-system)
    (arguments
      `(#:install-source? #f
        #:import-path "github.com/junegunn/fzf"))
    (inputs (list bash ncurses tmux))
    (home-page "https://github.com/junegunn/fzf")
    (synopsis "Command-line fuzzy finder")
    (description "fzf is a general-purpose command-line fuzzy finder.")
    (license license:expat)))
