;;;; Carapace shell completion
;;;; Why: Provides CLI completions for hundreds of commands (kubectl, docker, terraform, etc)
(define-public carapace
  (package
    (name "carapace")
    (version "1.6.4")
    (synopsis "Multi-shell completion library")
    (description "Carapace provides intelligent command completion for many CLI tools.")
    (home-page "https://carapace.sh")
    (license asl2.0)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/carapace-sh/carapace-bin/releases/download/v" version "/carapace-bin_" version "_linux_amd64.tar.gz"))
       (sha256 (base32 "1wpg8l0s6xcd7hjk3ifaqlkb9azdqik3j4nqa07ccndp1bwyjpl8"))
       (file-name (string-append "carapace-bin-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'build)
                  (delete 'check)
                  (delete 'configure)
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (install-file "carapace" (string-append out "/bin"))
                        #t))))))))
