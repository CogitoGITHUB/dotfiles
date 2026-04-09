(define-module (core-system user-space root shell archive unrar-free)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (unrar-free))

(define-public unrar-free
  (package
    (name "unrar-free")
    (version "0.3.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.com/bgermann/unrar-free")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "13qkflwcdfnyrajs3hf2hgrzq4l0kqzngxwa5vyqhw4zz0r9djpm"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))
    (home-page "https://gitlab.com/bgermann/unrar-free")
    (synopsis "Free unarchiver for RAR archives")
    (description "Unrar-free is a free utility to extract files from RAR archives.")
    (license license:gpl3+)))
