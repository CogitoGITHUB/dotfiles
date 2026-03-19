;;;; Git - Distributed version control system (needed for cloning repos)
(define-module (home packages version-control git)
  #:use-module (guix packages)
  #:use-module (gnu packages version-control))

(define-public git (package (inherit (@@ (gnu packages version-control) git))
  (name "git")
  (synopsis "Distributed version control system")))
