(define-module (core-system user-space root editors emacs-packages opencode)
  #:use-module (guix packages)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (core-system user-space root ai opencode)
  #:re-export (opencode)
  #:export (opencode-config))

;; Configuration metadata for opencode
;; OpenCode is the AI coding agent that powers literate development
(define opencode-config
  (list
    '(org-file . "opencode.org")
    '(version . "1.3.0")
    '(category . "ai")
    '(built-in . #f)
    '(defer . #f)))
