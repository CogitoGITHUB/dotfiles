(define-module (core-system user-space root editors emacs-packages avy)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (core-system user-space root editors emacs-packages literate-config-system)
  #:re-export (emacs-avy)
  #:export (avy-config))

;; Configuration metadata from avy.org
;; This tells the literate-config-system where to find the org file
;; and any load-time configuration
(define avy-config
  (make-lcs-config
    "avy.org"                    ; org-file: path to source .org
    "0.5.0"                      ; version
    '()                          ; depends: empty for now
    '()                          ; after: load after these packages
    #f                           ; built-in: not a built-in package
    #f))                         ; defer: load immediately
