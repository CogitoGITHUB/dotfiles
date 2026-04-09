(define-module (core-system user-space root desktop video mlt)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (mlt))

(define-public mlt
  (package
    (name "mlt")
    (version "7.36.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mltframework/mlt")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0kchbyh71bzw28s1hlifd49hqi4p2lliydy4h6xxlpkwi9pjp440"))))
    (build-system cmake-build-system)
    (home-page "https://www.mltframework.org/")
    (synopsis "Author, manage, and run multitrack audio/video compositions")
    (description "MLT is a multimedia framework designed for television broadcasting.")
    (license license:lgpl2.1+)))