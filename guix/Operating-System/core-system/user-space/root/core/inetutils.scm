(define-module (core-system user-space root core inetutils)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (inetutils))

(define-public inetutils
  (package
    (name "inetutils")
    (version "2.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://gnu/inetutils/inetutils-" version ".tar.gz"))
       (sha256
        (base32 "0q1257ci22g2jbdiqs00mharc1lqkbibdlkhj23f3si6qjxkn17s"))))
    (build-system gnu-build-system)
    (arguments
     '(#:configure-flags
       (list "--disable-syslogd"
             "--disable-ftpd"
             "--disable-telnetd"
             "--disable-whois"
             "--disable-ping"
             "--with-ncurses")
       #:tests? #f))
    (home-page "https://www.gnu.org/software/inetutils/")
    (synopsis "Network utilities")
    (description "GNU Inetutils provides various network utilities.")
    (license license:gpl3+)))
