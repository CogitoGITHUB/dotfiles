(define-module (core-system user-space root shell nushell)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages c)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:export (nushell))

(define-public nushell
  (package
    (name "nushell")
    (version "0.103.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "nu" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "1hpriinxjpwy4v99dd52gayhc2h3kmzkryzm5arm081kwaw33ay8"))))
    (build-system cargo-build-system)
    (arguments
      `(#:cargo-test-flags
        '("--"
          "--skip=path::canonicalize::canonicalize_tilde"
          "--skip=path::canonicalize::canonicalize_tilde_relative_to"
          "--skip=plugin_persistence"
          "--skip=plugins"
          "--skip=repl")
        #:install-source? #f))
    (native-inputs (list pkg-config))
    (inputs (cons* mimalloc openssl sqlite (cargo-inputs 'nushell)))
    (home-page "https://www.nushell.sh")
    (synopsis "Shell with a structured approach to the command line")
    (description
      "Nu draws inspiration from projects like PowerShell, functional
programming languages, and modern CLI tools.  Rather than thinking of files
and services as raw streams of text, Nu looks at each input as something with
structure.  For example, when you list the contents of a directory, what you
get back is a table of rows, where each row represents an item in that
directory.  These values can be piped through a series of steps, in a series
of commands called a ``pipeline''.")
    (license license:expat)))
