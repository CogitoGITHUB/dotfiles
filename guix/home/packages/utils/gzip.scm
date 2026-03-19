;;; Gzip compression utility
(define-public gzip (module-ref (resolve-interface '(gnu packages compression)) 'gzip))
