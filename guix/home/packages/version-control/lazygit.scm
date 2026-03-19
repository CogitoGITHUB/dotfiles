;;;; Lazygit - Simple terminal UI for git commands
(define-module (home packages version-control lazygit)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu))

(define-public lazygit
  (package
    (name "lazygit")
    (version "0.60.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/jesseduffield/lazygit/releases/download/v" version "/lazygit_" version "_Linux_x86_64.tar.gz"))
       (sha256
        (base32 "05dbz7vr4igicf1dh2jx0rxsbkqhb4i58ywj1lzgvi4bz5ncllk2"))
       (file-name (string-append "lazygit-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'configure)
                  (delete 'build)
                  (delete 'check)
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (install-file "lazygit" (string-append out "/bin"))
                        #t))))))
    (home-page "https://github.com/jesseduffield/lazygit")
    (synopsis "Simple terminal UI for git commands")
    (description "Lazygit is a simple terminal UI for git commands, written in Go.")
    (license license:expat)))