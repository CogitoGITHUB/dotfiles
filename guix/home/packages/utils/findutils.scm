;;;; Findutils - File search utilities
;;;; Why: Needed for finding files, glob patterns, AI agent work
(define-public findutils (module-ref (resolve-interface '(gnu packages base)) 'findutils))