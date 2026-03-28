(define-module (core-system user-space root loaders lsp)
  #:use-module (core-system user-space root lsp rust-analyzer)
  #:export (root-lsp-packages))

(define-public root-lsp-packages
  (list rust-analyzer))
