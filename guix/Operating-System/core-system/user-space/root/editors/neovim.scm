(define-module (core-system user-space root editors neovim)
  #:use-module (guix packages)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (neovim))

(define-public neovim
  (package
    (name "neovim")
    (version "0.11.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/neovim/neovim")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1b524vi44gkcsyy8w4jggvprwdsgy0gjprgxpyhh0dmqm47c0c48"))))
    (build-system cmake-build-system)
    (home-page "https://neovim.io/")
    (synopsis "Hyperextensible Vim-based text editor")
    (description "Neovim is a fork of Vim that aims to better the user's experience.")
    (license license:vim)))