(define-module (core-system user-space root ai)
  #:use-module (core-system user-space root ai opencode)
  #:re-export (opencode)
  #:export (root-ai-packages))

(define-public root-ai-packages
  (list opencode))
