(define-module (core-system user-space root shell archive zlib)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (zlib))

(define-public zlib
  (package
    (name "zlib")
    (version "1.3.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/madler/zlib/releases/download/v" version "/zlib-" version ".tar.xz"))
        (sha256 (base32 "0ciyi0zsggv32j27061y2d0jay8lg63q3iyr0wkx8475vyw9dvrq"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://zlib.net/")
    (synopsis "Compression library")
    (description "zlib compression library.")
    (license license:zlib)))