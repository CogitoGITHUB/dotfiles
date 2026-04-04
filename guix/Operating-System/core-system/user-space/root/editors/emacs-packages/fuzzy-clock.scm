(define-module (core-system user-space root editors emacs-packages fuzzy-clock)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-fuzzy-clock))

(define-public emacs-fuzzy-clock
  (package
    (name "emacs-fuzzy-clock")
    (version "0.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/Trevoke/fuzzy-clock.el")
                    (commit "congruence")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "03vpk4hffczjy882inxs6aybz30scrjv1g13iksfzry63kx877wa"))))
    (build-system emacs-build-system)
    (synopsis "Clock that tells time with configurable human-style granularity")
    (description "Fuzzy Clock displays time in Emacs the way humans naturally think about it. Instead of 14:32, you see \"Half past two\". Supports 11 levels of fuzziness from every 5 minutes to year.")
    (home-page "https://github.com/Trevoke/fuzzy-clock.el")
    (license license:gpl3+)))
