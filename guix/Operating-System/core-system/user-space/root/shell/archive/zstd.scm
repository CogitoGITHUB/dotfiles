(define-module (core-system user-space root shell archive zstd)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (zstd))

(define-public zstd
  (package
    (name "zstd")
    (version "1.5.6")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/facebook/zstd/releases/download/v" version "/zstd-" version ".tar.gz"))
        (sha256
          (base32 "1h83si7s70jy7mcy0mv1c9mbkz66qqpawxs0zkmc3b1ayinf0acc"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://facebook.github.io/zstd/")
    (synopsis "Fast lossless compression algorithm")
    (description "Zstandard is a real-time compression algorithm providing high compression ratios.")
    (license license:bsd-3)))
