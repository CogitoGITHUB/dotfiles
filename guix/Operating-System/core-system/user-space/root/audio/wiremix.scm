(define-module (core-system user-space root audio wiremix)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (wiremix))

(define-public wiremix
  (package
    (name "wiremix")
    (version "0.10.0")
    (source
      (origin
        (method url-fetch)
        (uri "file:///tmp/wiremix-build/bin/wiremix")
        (sha256 (base32 "1kapr56qzn0f7yyraxqw3d3z7mjm1k9b6i3vy0b62y7pcwnrq9f9"))))
    (build-system trivial-build-system)
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (let* ((out (assoc-ref %outputs "out"))
                       (src (assoc-ref %build-inputs "source")))
                  (mkdir-p (string-append out "/bin"))
                  (copy-file src (string-append out "/bin/wiremix"))
                  (chmod (string-append out "/bin/wiremix") #o755)))))
    (home-page "https://github.com/tsowell/wiremix")
    (synopsis "Simple TUI audio mixer for PipeWire")
    (description "wiremix is a TUI audio mixer for PipeWire for adjusting volumes, routing audio, and configuring audio device settings.")
    (license license:expat)))