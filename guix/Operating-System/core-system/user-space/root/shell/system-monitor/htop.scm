(define-module (core-system user-space root shell system-monitor htop)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages python)
  #:export (htop))

(define-public htop
  (package
    (name "htop")
    (version "3.4.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/htop-dev/htop")
              (commit version)))
        (sha256
          (base32 "058y4a4mvx9m179dyr4wi8mlm6i4ybywshadaj4cvfn9fv0r0nkx"))
        (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
      '(#:configure-flags (list "--enable-sensors")))
    (inputs (list ncurses lm-sensors))
    (native-inputs (list autoconf automake python-minimal-wrapper))
    (home-page "https://htop.dev")
    (synopsis "Interactive process viewer")
    (description "This is htop, an interactive process viewer for Linux.")
    (license license:gpl2+)))
