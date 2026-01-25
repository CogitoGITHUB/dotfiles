(define-module (headscale)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (gnu packages bash))

(define-public headscale
  (package
    (name "headscale")
    (version "0.27.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/juanfont/headscale/releases/download/v"
                    version "/headscale_" version "_linux_amd64"))
              (sha256
               (base32
                "003crclv12sa327blpnyx2rgvixgxbydid40b7q01h87yhpj6amg"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("headscale_0.27.1_linux_amd64" "bin/headscale"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'make-executable
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin/headscale")))
               (chmod bin #o755)))))))
    (inputs (list bash))
    (synopsis "Open source Tailscale control server implementation")
    (description
     "Headscale is an open source, self-hosted implementation of the Tailscale
control server.  It implements a self-hosted, open source alternative to the
Tailscale control server suitable for personal use or small organizations.")
    (home-page "https://github.com/juanfont/headscale")
    (license bsd-3)))
