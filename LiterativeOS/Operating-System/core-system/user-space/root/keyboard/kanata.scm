(define-module (core-system user-space root keyboard kanata)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (kanata))

(define-public kanata
  (package
    (name "kanata")
    (version "1.11.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/jtroo/kanata/releases/download/v1.11.0/linux-binaries-x64.zip")
        (sha256 (base32 "1qmlb5a54hgri65c8v19hd6jshsvss7rkwxc5b67iw67njpk9xnr"))))
    (build-system trivial-build-system)
    (inputs (list unzip))
    (arguments
      (list #:modules (quote ((guix build utils)))
            #:builder
        (quasiquote (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (unzip (string-append (assoc-ref %build-inputs "unzip") "/bin/unzip")))
            (mkdir-p (string-append out "/bin"))
            (invoke unzip "-j" src "kanata_linux_x64" "-d" (string-append out "/bin"))
            (rename-file (string-append out "/bin/kanata_linux_x64")
                         (string-append out "/bin/kanata")))))))
    (home-page "https://github.com/jtroo/kanata")
    (synopsis "Keyboard remapper")
    (description "Kanata is a keyboard remapper for Linux.")
    (license license:lgpl3)))