(define-module (core-system user-space root editors emacs-packages emacs-ht)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages emacs-build)
  #:export (emacs-ht))

(define-public emacs-ht
  (let ((commit "1c49aad1c820c86f7ee35bf9fff8429502f60fef")
        (revision "0"))
    (package
      (name "emacs-ht")
      (version (git-version "2.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Wilfred/ht.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1vyk81xav1ghdb39fqi99yf6yvzsh6p007v7yhzk1bbqqffkvqdj"))))
      (build-system emacs-build-system)
      (propagated-inputs (list emacs-dash))
      (home-page "https://github.com/Wilfred/ht.el")
      (synopsis "Hash table library for Emacs")
      (description "This package simplifies the use of hash tables in elisp.")
      (license license:gpl3+))))
