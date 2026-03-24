(define-module (core-system user-space root core sudo)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:export (sudo))

(define-public sudo
  (package
    (name "sudo")
    (version "1.9.17p1")
    (source
     (origin
       (method url-fetch)
       (uri
        (list (string-append "https://www.sudo.ws/sudo/dist/sudo-"
                            version ".tar.gz")))
       (sha256
        (base32 "0cjx8lkwlqz03psnaia07rz9mpyn5ilpixvqi9rrf8872ykpwq7z"))
       (modules '((guix build utils)))
       (snippet
        '(begin
           (delete-file-recursively "lib/zlib")))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "--docdir=" #$output
                            "/share/doc/" #$name "-" #$version)
              "--with-logpath=/var/log/sudo.log"
              "--with-rundir=/var/run/sudo"
              "--with-vardir=/var/db/sudo"
              "--with-iologdir=/var/log/sudo-io")
      #:parallel-build? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'configure 'pre-configure
            (lambda _
              (substitute* "src/sudo_usage.h.in"
                (("@CONFIGURE_ARGS@")
                 "\"\"")))))))
    (home-page "https://www.sudo.ws/")
    (synopsis "Run commands as root")
    (description "Sudo allows a permitted user to execute commands as root.")
    (license license:isc)))
