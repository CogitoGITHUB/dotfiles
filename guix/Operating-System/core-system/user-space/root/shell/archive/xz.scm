(define-module (core-system user-space root shell archive xz)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (xz))

(define-public xz
  (package
    (name "xz")
    (version "5.4.5")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "http://tukaani.org/xz/xz-" version ".tar.gz"))
        (sha256
          (base32 "1mmpwl4kg1vs6n653gkaldyn43dpbjh8gpk7sk0gps5f6jwr0p0k"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://tukaani.org/xz/")
    (synopsis "XZ compression utility")
    (description "XZ Utils is general-purpose compression software.")
    (license license:gpl2+)))
