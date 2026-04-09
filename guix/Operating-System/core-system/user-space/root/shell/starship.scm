(define-module (core-system user-space root shell starship)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (starship))

(define-public starship
  (package
    (name "starship")
    (version "1.24.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "starship" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0q57nb66fww6c8kwfyl5dpv9c2gr721nbbqcpsrh9c6wd6c26339"))))
    (build-system cargo-build-system)
    (arguments
     '(#:install-source? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'install-completions
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (mkdir-p (string-append out "/share/bash-completion/completions"))
               (mkdir-p (string-append out "/share/zsh/site-functions"))
               (invoke (string-append out "/bin/starship") "completions" "bash")
               (invoke (string-append out "/bin/starship") "completions" "zsh")
               #t))))))
    (home-page "https://starship.rs")
    (synopsis
     "The minimal, blazing-fast, and infinitely customizable prompt for any shell!")
    (description
     "This package provides The minimal, blazing-fast, and infinitely customizable
prompt for any shell!")
    (license license:isc)))
