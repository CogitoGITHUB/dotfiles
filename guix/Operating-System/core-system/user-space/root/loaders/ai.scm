(define-module (core-system user-space root loaders ai)
  #:use-module (core-system user-space root ai opencode)
  #:use-module (core-system user-space root ai ollama)
  #:re-export (opencode ollama)
  #:export (root-ai-packages))

(define-public root-ai-packages
  (list opencode ollama))
