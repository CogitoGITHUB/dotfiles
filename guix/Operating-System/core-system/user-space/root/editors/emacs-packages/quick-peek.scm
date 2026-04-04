(define-module (core-system user-space root editors emacs-packages quick-peek)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-quick-peek))

(define-public emacs-quick-peek
  (package
    (name "emacs-quick-peek")
    (version "1.0.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/clemera/quick-peek")
                    (commit "03a276086795faad46a142454fc3e28cab058b70")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1kzsphzc9n80v6vf00dr2id9qkm78wqa6sb2ncnasgga6qj358ql"))))
    (build-system emacs-build-system)
    (synopsis "Display overlays on top of text")
    (description "This package provides a way to display overlays on top of text, useful for showing help, previews, and other contextual information without disrupting the buffer.")
    (home-page "https://github.com/clemera/quick-peek")
    (license license:gpl3+)))
