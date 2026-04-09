(define-module (core-system user-space root networking yt-dlp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system pyproject)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python-compression)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages music)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages video)
  #:export (yt-dlp))

(define-public yt-dlp
  (package
    (name "yt-dlp")
    (version "2026.03.17")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/yt-dlp/yt-dlp/")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0d146j9vgdycjhih61nw9g75d4isflfkgr50d7ka3n21cjc86i4j"))))
    (build-system pyproject-build-system)
    (arguments '(#:tests? #f))
    (inputs (list python-brotli python-certifi python-mutagen
                  python-pycryptodomex python-requests python-urllib3))
    (home-page "https://github.com/yt-dlp/yt-dlp")
    (synopsis "Download videos from YouTube.com and other sites")
    (description "yt-dlp is a command-line program to download videos from YouTube.com and many other sites.")
    (license license:public-domain)))
