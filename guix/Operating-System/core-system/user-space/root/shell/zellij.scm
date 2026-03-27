(define-module (core-system user-space root shell zellij)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (zellij))

(define-public zellij
  (package
    (name "zellij")
    (version "0.42.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/zellij-org/zellij/releases/download/v" version
              "/zellij-x86_64-unknown-linux-musl.tar.gz"))
        (sha256 (base32 "0s16924xx02d788gk5qbh13fw45d8zkmj2wrz5kw4d1ivnqj237b"))))
    (build-system trivial-build-system)
    (inputs (list tar gzip))
    (arguments
      (list #:modules (quote ((guix build utils)))
            #:builder
        (quasiquote (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                 (gzip (string-append (assoc-ref %build-inputs "gzip") "/bin")))
            (setenv "PATH" gzip)
            (mkdir-p (string-append out "/bin"))
            (invoke tar "-xzf" src "-C" (string-append out "/bin")))))))
    (home-page "https://zellij.dev")
    (synopsis "Terminal workspace")
    (description "Zellij is a terminal workspace with multiplexed terminals.")
    (license license:asl2.0)))