;; Zoxide - cd utility
(define-module (literativeos packages zoxide)
  #:use-module (guix packages)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages rust))

(define-public zoxide
  (package
    (name "zoxide")
    (version "0.9.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ajeetdsouza/zoxide")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0v2kr5p7c2b0r4n9k4j7x1y6w8z5q3m0"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-build-features "generate-bash-hook generate-fish-hook generate-zsh-hook"
       #:phases
       (modify-phases %standard-phases
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (install-file "target/release/zoxide" (string-append out "/bin"))
               (install-file "contrib/completion/zoxide.bash"
                            (string-append out "/share/bash-completion/completions"))
               (install-file "contrib/completion/_zoxide"
                            (string-append out "/share/zsh/site-functions"))
               (install-file "contrib/completion/zoxide.fish"
                            (string-append out "/share/fish/vendor_completions.d")))))))
    (home-page "https://github.com/ajeetdsouza/zoxide")
    (synopsis "Shell extension for cd that learns your habits")
    (description "zoxide is a cd utility that learns your most frequently used directories and makes them available with just a few keystrokes.")
    (license license:expat)))
