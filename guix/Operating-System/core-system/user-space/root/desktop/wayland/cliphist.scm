(define-module (core-system user-space root desktop wayland cliphist)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (cliphist))

(define-public cliphist
  (package
    (name "cliphist")
    (version "0.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/sentriz/cliphist")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dffcpqmqd9drgc7l95kbqh199ljhhqw468x17m4bwv3y2bm50fb"))))
    (build-system go-build-system)
    (arguments
     '(#:install-source? #f
       #:import-path "go.senan.xyz/cliphist"))
    (home-page "https://github.com/sentriz/cliphist")
    (synopsis "Wayland clipboard manager")
    (description "Clipboard manager for Wayland.")
    (license license:gpl3+)))
