(define-module (core-system user-space root editors emacs-packages)
  #:use-module (core-system user-space root editors emacs-packages geiser)
  #:use-module (core-system user-space root editors emacs-packages emacs-sops)
  #:re-export (emacs-geiser emacs-geiser-guile emacs-sops)
  #:export (root-emacs-packages))

(define-public root-emacs-packages
  (list emacs-geiser emacs-geiser-guile emacs-sops))