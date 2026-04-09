(define-module (core-system user-space root security age)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system go)
  #:use-module (gnu packages)
  #:use-module (gnu packages golang-crypto))

;; Simplified from gnu/packages/golang-crypto.scm
;; Provides the age CLI tool (command line interface)
(define-public age
  (package
    (inherit go-filippo-io-age)
    (name "age")
    (arguments
     (list #:install-source? #f
           #:import-path "filippo.io/age/cmd/age"
           #:tests? #f))
    (description
     "Simple, modern, and secure file encryption tool with a command-line interface.")
    (synopsis "Simple, modern, and secure file encryption CLI")))
