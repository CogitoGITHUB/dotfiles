(define-module (core-system user-space root ai n8n)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages node)
  #:use-module (gnu packages base)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive gzip)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (n8n))

;; Phase 1: FOD for n8n's node_modules dependency tree.
;; Downloads the npm tarball, unpacks it, runs `npm install --ignore-scripts`
;; from inside the package directory to resolve all dependencies from the
;; npm registry, then copies node_modules to the output.
(define n8n-node-modules
  (package
    (name "n8n-node-modules")
    (version "2.14.2")
    (source (origin
              (method url-fetch)
              (uri "https://registry.npmjs.org/n8n/-/n8n-2.14.2.tgz")
              (sha256
               (base32
                "19rp3cqmbh9nymdzw0zkxkz3al5x37dijwyygywcw600ph8bjplv"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (node (assoc-ref %build-inputs "node"))
                 (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                 (gzip (string-append (assoc-ref %build-inputs "gzip") "/bin/gzip"))
                 (npm (string-append node "/bin/npm")))
            (setenv "HOME" "/tmp")
            (setenv "PATH" (string-append node "/bin"))
            ;; Unpack tarball: creates package/ directory
            (invoke tar "--use-compress-program" gzip "-xf" src)
           (chdir "package")
           ;; Install all dependencies from npm registry
           (invoke npm "install"
                   "--ignore-scripts"
                   "--no-audit"
                   "--no-fund"
                   "--production")
           ;; Copy node_modules to output
           (copy-recursively "node_modules" out)))))
    (inputs (list node tar gzip))
    (outputs '("out"))
    (home-page "https://n8n.io")
    (synopsis "node_modules dependency tree for n8n")
    (description "Fixed-output derivation containing the complete
node_modules dependency tree for n8n @code{2.14.2}, installed with
@code{npm install --ignore-scripts --production}.")
    (license license:expat)))

;; Phase 2: Main n8n package — combines the npm tarball with the FOD
;; node_modules and creates a wrapper script.
(define-public n8n
  (package
    (name "n8n")
    (version "2.14.2")
    (source (origin
              (method url-fetch)
              (uri "https://registry.npmjs.org/n8n/-/n8n-2.14.2.tgz")
              (sha256
               (base32
                "19rp3cqmbh9nymdzw0zkxkz3al5x37dijwyygywcw600ph8bjplv"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let* ((out   (assoc-ref %outputs "out"))
                (bin   (string-append out "/bin"))
                (lib   (string-append out "/lib/node_modules/n8n"))
                (tar   (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                (gzip  (string-append (assoc-ref %build-inputs "gzip") "/bin/gzip"))
                (nm-src (assoc-ref %build-inputs "n8n-node-modules"))
                (node  (string-append (assoc-ref %build-inputs "node") "/bin/node")))
           (mkdir-p lib)
           (mkdir-p bin)
           ;; Unpack the npm tarball (contains bin/, dist/, templates/)
           (invoke tar "--use-compress-program" gzip "-xf" (assoc-ref %build-inputs "source") "--strip-components=1" "-C" lib)
           ;; Link the FOD's node_modules into the package
           (symlink nm-src (string-append lib "/node_modules"))
           ;; Create wrapper script using absolute store path to node
           (call-with-output-file (string-append bin "/n8n")
             (lambda (p)
               (format p "#!/bin/sh\nexec ~a ~a/bin/n8n \"$@\"\n"
                       node lib)))
           (chmod (string-append bin "/n8n") #o755)))))
    (inputs (list node tar gzip n8n-node-modules))
    (outputs '("out"))
    (home-page "https://n8n.io")
    (synopsis "Fair-code workflow automation platform")
    (description "n8n is a workflow automation platform that gives technical
teams the flexibility of code with the speed of no-code. With 400+ integrations,
native AI capabilities, and a fair-code license, n8n lets you build powerful
automations while maintaining full control over your data and deployments.")
    (license license:expat)))

n8n
