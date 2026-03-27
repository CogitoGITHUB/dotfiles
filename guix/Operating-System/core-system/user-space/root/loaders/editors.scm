(define-module (core-system user-space root loaders editors)
  #:use-module (core-system user-space root editors emacs)
  #:use-module (core-system user-space root editors neovim)
  #:use-module (core-system user-space root editors emacs-packages)
  #:re-export (emacs neovim)
  #:export (root-editors-packages))

(define-public root-editors-packages
  (append (list emacs neovim) root-emacs-packages))