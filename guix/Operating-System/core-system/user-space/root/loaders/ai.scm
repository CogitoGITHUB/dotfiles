(define-module (core-system user-space root loaders ai)
  #:use-module (core-system user-space root ai openclaw)
  #:use-module (core-system user-space root ai opencode)
  #:use-module (core-system user-space root ai kilo)
  #:re-export (openclaw opencode kilo)
  #:export (root-ai-packages))

(define-public root-ai-packages
  (list openclaw opencode kilo))