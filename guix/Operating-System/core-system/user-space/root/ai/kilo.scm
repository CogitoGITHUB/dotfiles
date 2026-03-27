(define-module (core-system user-space root ai kilo)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (kilo))

(define-public kilo
  (package
    (name "kilo")
    (version "7.1.8")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/Kilo-Org/kilocode/releases/download/v" version
              "/kilo-linux-x64.tar.gz"))
        (sha256 (base32 "0y5yybnn4rbkbp4ihalk6nr18rpi3zq3yj0i9s406ig32r4bp64j"))))
    (build-system trivial-build-system)
    (inputs (list tar gzip patchelf glibc))
    (arguments
      (list #:modules (quote ((guix build utils)))
            #:builder
        (quasiquote (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                 (gzip (string-append (assoc-ref %build-inputs "gzip") "/bin"))
                 (patchelf (string-append (assoc-ref %build-inputs "patchelf") "/bin/patchelf"))
                 (interp (string-append (assoc-ref %build-inputs "glibc") "/lib/ld-linux-x86-64.so.2")))
            (setenv "PATH" gzip)
            (mkdir-p (string-append out "/bin"))
            (invoke tar "-xzf" src "-C" (string-append out "/bin"))
            (invoke patchelf "--set-interpreter" interp
                    (string-append out "/bin/kilo")))))))
    (home-page "https://kilo.code")
    (synopsis "The AI coding agent built for the terminal")
    (description "Kilo is the all-in-one agentic engineering platform. Build, ship, and iterate faster with the most popular open source coding agent.")
    (license license:expat)))
