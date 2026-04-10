(define-module (core-system user-space root ai openclaw)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages node)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive gzip)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (openclaw))

(define-public openclaw
  (package
    (name "openclaw")
    (version "2026.3.28")
    (source (local-file "sources/openclaw-2026.3.28.tar.gz"))
    (build-system trivial-build-system)
    (propagated-inputs (list node))
    (inputs (list tar gzip))
    (arguments
     (list #:modules (quote ((guix build utils)))
           #:builder
           (quasiquote
            (begin
              (use-modules (guix build utils))
              (let* ((out (assoc-ref %outputs "out"))
                     (src (assoc-ref %build-inputs "source"))
                     (tar-bin (string-append (assoc-ref %build-inputs "tar") "/bin"))
                     (gzip-bin (string-append (assoc-ref %build-inputs "gzip") "/bin"))
                     (node-bin (string-append (assoc-ref %build-inputs "node") "/bin/node"))
                     (openclaw-entry (string-append out "/node_modules/openclaw/openclaw.mjs"))
                     (openclaw-bin (string-append out "/bin/openclaw")))
                (setenv "PATH" (string-append tar-bin ":" gzip-bin))
                (mkdir-p out)
                (invoke (string-append tar-bin "/tar") "xzf" src "-C" out)
                (mkdir-p (string-append out "/bin"))
                (call-with-output-file openclaw-bin
                  (lambda (port)
                    (format port "#!/bin/sh\nexec ~a ~a \"$@\"\n"
                            node-bin
                            openclaw-entry)))
                (chmod openclaw-bin #o555))))))
    (home-page "https://github.com/openclaw/openclaw")
    (synopsis "Multi-channel AI gateway with extensible messaging integrations")
    (description "OpenClaw is an open-source CLI framework for building AI-powered messaging assistants.")
    (license license:expat)))
