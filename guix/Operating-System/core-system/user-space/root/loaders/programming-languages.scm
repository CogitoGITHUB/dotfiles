(define-module (core-system user-space root loaders programming-languages)
  #:use-module (core-system user-space root programming-languages lisp)
  #:export (root-programming-languages-packages))

(define root-programming-languages-packages (list guile))