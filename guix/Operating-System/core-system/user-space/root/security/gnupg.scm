(define-module (core-system user-space root security gnupg)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages openldap)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages security-token)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages sqlite)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive zlib)
  #:export (gnupg))

;; Simplified from gnu/packages/gnupg.scm
(define-public gnupg
  (package
    (name "gnupg")
    (version "2.4.8")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnupg/gnupg/gnupg-" version
                                  ".tar.bz2"))
              (sha256
               (base32
                "05l666aha1nxpiiras446zmkhcgqnp33y74wyhzj9lq4kgbq135m"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config))
    (inputs
     (list gnutls
           libassuan
           libgcrypt
           libgpg-error
           libksba
           npth
           openldap
           pcsc-lite
           readline
           sqlite
           zlib))
    (home-page "https://gnupg.org/")
    (synopsis "GNU Privacy Guard")
    (description
     "The GNU Privacy Guard is a complete implementation of the OpenPGP
standard. It is used to encrypt and sign data and communication.")
    (license license:gpl3+)))