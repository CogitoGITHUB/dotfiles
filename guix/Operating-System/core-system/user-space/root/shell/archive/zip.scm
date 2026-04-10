(define-module (core-system user-space root shell archive zip)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (core-system user-space root shell archive unzip)
  #:export (zip))

(define-public zip
  (package
    (name "zip")
    (version "3.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "mirror://sourceforge/infozip/Zip%203.x%20%28latest%29/3.0/zip30.tar.gz"))
        (sha256
          (base32 "0sb3h3067pzf3a7mlxn1hikpcjrsvycjcnj9hl9b1c3ykcgvps7h"))))
    (build-system gnu-build-system)
    (inputs (list bzip2))
    (arguments '(#:tests? #f))
    (home-page "https://www.info-zip.org/")
    (synopsis "Create ZIP archives")
    (description "Zip is a compression and file packaging utility.")
    (license license:bsd-3)))
