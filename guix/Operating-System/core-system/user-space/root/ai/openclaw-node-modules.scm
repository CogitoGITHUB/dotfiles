(define-module (core-system user-space root ai openclaw-node-modules)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages node)
  #:use-module (gnu packages bash)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (openclaw-node-modules))

(define-public openclaw-node-modules
  (package
    (name "openclaw-node-modules")
    (version "2026.3.28")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://registry.npmjs.org/openclaw/-/openclaw-" version ".tgz"))
        (sha256 (base32 "1hpdqfpnvc4hz8ggf9kvfg1q0l8gpjm1hzpkfgvh4k6iylwrlw7x"))))
    (build-system trivial-build-system)
    (inputs (list node bash))
    (arguments
     (list #:modules (quote ((guix build utils)))
           #:builder
           (quasiquote
            (begin
              (use-modules (guix build utils))
              (let* ((out (assoc-ref %outputs "out"))
                     (src (assoc-ref %build-inputs "source"))
                     (node (assoc-ref %build-inputs "node"))
                     (npm (string-append node "/bin/npm")))
                (setenv "PATH" (string-append node "/bin"))
                (setenv "HOME" "/tmp")
                (invoke "tar" "xzf" src)
                (chdir "package")
                (invoke npm "install" "--production")
                (copy-recursively "node_modules" out))))))
    (home-page "https://github.com/openclaw/openclaw")
    (synopsis "Node modules for openclaw")
    (description "Pre-installed node_modules for openclaw.")
    (license license:expat)))
