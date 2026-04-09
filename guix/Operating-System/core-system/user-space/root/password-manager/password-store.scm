(define-module (core-system user-space root password-manager password-store)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (password-store))

(define-public password-store
  (package
    (name "password-store")
    (version "1.7.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "git://git.zx2c4.com/password-store")
             (commit version)))
       (sha256
        (base32
         "17zp9pnb3i9sd2zn9qanngmsywrb7y495ngcqs6313pv3gb83v53"))
       (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (home-page "https://www.passwordstore.org/")
    (synopsis "Unix password manager")
    (description "password-store is a simple password manager using GPG and Git.")
    (license license:gpl2+)))