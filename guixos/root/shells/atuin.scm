;; Atuin - Magical shell history
;; Simple binary package - downloads pre-built binary

(define-module (shells atuin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public atuin
  (package
    (name "atuin")
    (version "18.2.0")
    (synopsis "Magical shell history with SQLite backend")
    (description "Atuin replaces your existing shell history with a SQLite database")
    (home-page "https://github.com/atuinsh/atuin")
    (license license:expat)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/atuinsh/atuin/releases/download/v" version "/atuin-v" version "-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "04s3apdb80d4dsa5aklzw1bwq9zd7s67pxkdq6mwbbvn7ymdlf6h"))
       (file-name (string-append "atuin-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     '(#:tests? #f
       #:strip-binaries? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (install-file "atuin" (string-append out "/bin"))
               #t))))))))

atuin
