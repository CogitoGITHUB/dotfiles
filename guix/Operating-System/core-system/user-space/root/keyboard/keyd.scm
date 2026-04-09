;; Simplified full package declaration for keyd
(define-module (core-system user-space root keyboard keyd)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:))

(define-public keyd
  (package
    (name "keyd")
    (version "2.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/rvaiya/keyd")
              (commit (string-append "v" version))))
       (sha256
         (base32 "14rgrg8d1ys1cqq46mgi34yqg9jd1q3yw1acw5r5jpwwk0da7g4p"))))
    (arguments
     '(#:tests? #f
       #:make-flags
       (list "CC=gcc" "PREFIX=")))
    (build-system gnu-build-system)
    (inputs (list))
    (synopsis "Key remapping daemon for Linux")
    (description
     "Keyd is a keyboard remapping utility with intuitive ini configuration.")
    (home-page "https://github.com/rvaiya/keyd")
    (license license:expat)))
