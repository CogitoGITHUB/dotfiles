(define-module (core-system user-space root security age)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (age))

(define-public go-filippo-io-age
  (package
    (name "go-filippo-io-age")
    (version "1.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/FiloSottile/age")
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1h4k15bdbx5dx1397xvhx2h7b5akvbzksh80j3p46mqq6kgymks2"))
       (modules '((guix build utils)))
       (snippet
        '(begin
            (with-directory-excursion "doc"
              (for-each delete-file '("age.1.html"
                                      "age-keygen.1.html"
                                      "age-keygen.1.ronn"
                                      "age.1.ronn")))))))
    (build-system go-build-system)
    (arguments
     '(#:build-flags (list (string-append "-ldflags=-X main.Version=" ,version))
       #:embed-files '("armor.*" "header_crlf" "hmac_.*" "scrypt.*"
                     "stanza_.*" "stream_.*" "version_unsupported"
                     "x25519.*" "x25519_.*")
       #:import-path "filippo.io/age"))
    (home-page "https://filippo.io/age")
    (synopsis "Secure file encryption tool, format, and Go library")
    (description "This package implements file encryption according to the age specification.")
    (license license:bsd-3)))

(define-public age
  (package
    (inherit go-filippo-io-age)
    (name "age")
    (arguments
     '(#:tests? #f
       #:install-source? #f
       #:unpack-path ""
       #:phases
       (modify-phases (standard-phases)
         (replace 'build
           (lambda* (#:key import-path #:allow-other-keys #:rest arguments)
             (for-each
              (lambda (cmd)
                (apply (assoc-ref (standard-phases) 'build)
                       `(,@arguments
                         #:import-path ,(string-append import-path cmd))))
              (list "/cmd/age"
                    "/cmd/age-keygen"))))
         (add-after 'install 'install-man-pages
           (lambda _
             (let ((man (string-append output "/man/man1/")))
               (mkdir-p man)
               (install-file "src/filippo.io/age/doc/age.1" man)
               (install-file "src/filippo.io/age/doc/age-keygen.1" man)))))))
    (native-inputs '())
    (propagated-inputs '())
    (inputs '())
    (description
     (string-append (package-description go-filippo-io-age)
                    "This package provides a command line interface (CLI) tool."))))