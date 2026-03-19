(define-module (shells starship)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:))

(define-public starship
  (package
    (name "starship")
    (version "1.21.0")
    (synopsis "Minimal, blazing-fast, and customizable prompt for any shell")
    (description "The minimal, blazing-fast, and infinitely customizable prompt for any shell.")
    (home-page "https://starship.rs")
    (license license:expat)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/starship/starship/releases/download/v" version "/starship-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "1gdpclq48jk501asckpn6dfjphgwzcjxxk3xbpws0bwrx7y382ln"))
       (file-name (string-append "starship-" version ".tar.gz"))))
    (build-system copy-build-system)))
