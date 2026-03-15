;; Emacs configuration
;; Loads emacs core modules

(define-module (emacs)
  #:use-module (emacs core init)
  #:use-module (emacs core packages))

;; Exports
export emacs-core-init
export emacs-packages
