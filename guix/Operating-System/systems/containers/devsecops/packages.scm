(define-module (systems containers devsecops packages)
  #:use-module (gnu packages nmap)
  #:export (devsecops-packages))

(define-public devsecops-packages
  (list nmap))
