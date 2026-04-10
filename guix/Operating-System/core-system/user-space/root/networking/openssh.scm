;; Simplified full package declaration for openssh
(define-module (core-system user-space root networking openssh)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (srfi srfi-1)
  #:use-module (core-system user-space root shell archive zlib))

(define-public openssh
  (package
    (name "openssh")
    (version "10.2p1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://openbsd/OpenSSH/portable/"
                           "openssh-" version ".tar.gz"))
       (sha256
        (base32 "1clqyxh6mrbwjg964df0hjwmd361mxnx3nx17wk5jyck3422ri6c"))))
    (build-system gnu-build-system)
    (arguments
     '(#:test-target "tests"
       #:parallel-tests? #f))
    (native-inputs (list groff pkg-config))
    (inputs (list libedit openssl zlib))
    (synopsis "Client and server for the secure shell (ssh) protocol")
    (description
     "The SSH2 protocol implemented in OpenSSH is standardised by the
IETF secsh working group.")
    (license (non-copyleft "file://LICENSE"))
    (home-page "https://www.openssh.com/")))
