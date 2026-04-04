(define-module (core-system user-space root loaders ai)
  #:use-module (core-system user-space root ai openclaw)
  #:use-module (core-system user-space root ai opencode)
  #:use-module (core-system user-space root ai kilo)
  #:use-module (core-system user-space root ai ollama)
  ;; #:use-module (core-system user-space root ai n8n)
  #:re-export (openclaw opencode kilo ollama) ;; n8n
  #:export (root-ai-packages))

(define-public root-ai-packages
  (list openclaw opencode kilo ollama)) ;; n8n
