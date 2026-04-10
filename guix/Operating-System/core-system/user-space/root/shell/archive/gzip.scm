(define-module (core-system user-space root shell archive gzip)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (gzip))

(define-public gzip
  (package
    (name "gzip")
    (version "1.13")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "http://ftp.gnu.org/gnu/gzip/gzip-" version ".tar.xz"))
        (sha256
          (base32 "0mx0j7765l4cyj3hyvlks2s3izdyzaqf3hknamjwc5yv6mlynm3l"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://www.gnu.org/software/gzip/")
    (synopsis "GNU zip compression utility")
    (description "GNU gzip compression utility.")
    (license license:gpl3+)))