(define-module (core-system user-space home loaders emacs)
  #:use-module (core-system user-space home emacs daemon)
  #:re-export (home-emacs-daemon-service)
  #:export (home-emacs-services))

(define-public home-emacs-services
  (list home-emacs-daemon-service))
