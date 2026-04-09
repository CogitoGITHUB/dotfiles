(define-module (core-system user-space root shell archive unzip)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (unzip))

(define-public unzip
  (package
    (name "unzip")
    (version "6.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "mirror://sourceforge/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz"))
        (sha256
          (base32 "0dxx11knh3nk95p2gg2ak777dd11pr7jx5das2g49l262scrcv83"))
        (patches (list (search-patch "unzip-CVE-2014-8139.patch")
                       (search-patch "unzip-CVE-2014-8140.patch")
                       (search-patch "unzip-CVE-2014-8141.patch")
                       (search-patch "unzip-CVE-2014-9636.patch")))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://www.info-zip.org/")
    (synopsis "Extract ZIP archives")
    (description "Unzip is a decompression and file extraction utility for ZIP archives.")
    (license license:bsd-3)))
