(define-module (core-system user-space root containers docker)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (docker))

;; Docker version
(define %docker-version "28.1.0")

(define-public docker
  (package
    (name "docker")
    (version %docker-version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/moby/moby")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
        (sha256
         (base32 "14lmpj804lp1yvpaymsx1xv5d93ksznqv3qbbv96y02dy05w6zfs"))))
    (build-system gnu-build-system)
    (home-page "https://www.docker.com/")
    (synopsis "Set of programs to manage container images and containers")
    (description "Docker is a platform for developing, shipping, and running applications in containers.")
    (license license:asl2.0)))