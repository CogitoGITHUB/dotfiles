(define-module (core-system user-space root loaders formatters)
  #:use-module (core-system user-space root formatters nixfmt)
  #:use-module (core-system user-space root formatters ruff)
  #:use-module (core-system user-space root formatters latexindent)
  #:use-module (core-system user-space root formatters prettier)
  #:export (root-formatters-packages))

(define-public root-formatters-packages
  (list nixfmt
        ruff
        texlive-latexindent
        node))
