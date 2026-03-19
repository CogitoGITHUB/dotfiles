;;;; Starship prompt - Blazing-fast customizable prompt for any shell
;;;; Why: Powers the nushell prompt with git status, runtime, etc.
(define-public starship
  (package
    (name "starship")
    (version "1.21.0")
    (synopsis "Minimal, blazing-fast, and customizable prompt for any shell")
    (description "The minimal, blazing-fast, and infinitely customizable prompt for any shell.")
    (home-page "https://starship.rs")
    (license expat)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/starship/starship/releases/download/v" version "/starship-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "1gdpclq48jk501asckpn6dfjphgwzcjxxk3xbpws0bwrx7y382ln"))
       (file-name (string-append "starship-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'build)
                  (delete 'check)
                  (delete 'configure)
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (install-file "starship" (string-append out "/bin"))
                        #t))))))))