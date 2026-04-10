(define-module (core-system user-space root shell archive unzip)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (unzip))

(define-public unzip
  (package
    (name "unzip")
    (version "6.0")
    (source
     (origin
       (method url-fetch)
       (uri "mirror://sourceforge/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz")
       (sha256
        (base32 "0dxx11knh3nk95p2gg2ak777dd11pr7jx5das2g49l262scrcv83"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://www.info-zip.org/")
    (synopsis "Extract ZIP archives")
    (description "Unzip is a decompression and file extraction utility for ZIP archives.")
    (license license:bsd-3)))
