(define-module (core-system user-space root ai opencode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (opencode))

(define-public opencode
  (package
    (name "opencode")
    (version "1.3.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/anomalyco/opencode/releases/download/v" version
              "/opencode-linux-x64.tar.gz"))
        (sha256 (base32 "0ac4x69fgg1q7qhgipkladgxg9nz9n9arvqnxq59nyd2ylgjsnmy"))))
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
                    (string-append out "/bin/opencode")))))))
    (home-page "https://opencode.ai")
    (synopsis "The open source AI coding agent")
    (description "OpenCode is an AI coding agent built for the terminal.")
    (license license:expat)))