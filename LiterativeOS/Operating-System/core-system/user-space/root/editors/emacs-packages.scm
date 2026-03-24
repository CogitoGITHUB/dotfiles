(define-module (core-system user-space root editors emacs-packages)
  #:use-module (core-system user-space root editors emacs-packages geiser)
  #:re-export (emacs-geiser emacs-geiser-guile)
  #:export (root-emacs-packages))

(define-public root-emacs-packages
  (list emacs-geiser emacs-geiser-guile))