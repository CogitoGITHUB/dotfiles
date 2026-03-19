;;;; Atuin shell history - Cloud-sync shell history with search
;;;; Why: Enhanced shell history with full-text search and sync across machines
(define-public atuin
  (package
    (name "atuin")
    (version "18.13.3")
    (synopsis "Shell history with cloud sync")
    (description "Atuin replaces your existing shell history with a SQLite database, recording significantly more information about your context.")
    (home-page "https://atuin.sh")
    (license expat)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/atuinsh/atuin/releases/download/v" version "/atuin-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "0s184mnkz6hmiy2bc2gf2ywx817vniz3075jz25zjpmpkq27yd5r"))
       (file-name (string-append "atuin-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'build)
                  (delete 'check)
                  (delete 'configure)
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (install-file "atuin" (string-append out "/bin"))
                        (install-file "atuin" (string-append out "/bin/atuin-hook"))
                        #t))))))))