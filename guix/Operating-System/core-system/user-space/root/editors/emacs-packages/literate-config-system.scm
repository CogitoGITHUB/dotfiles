(define-module (core-system user-space root editors emacs-packages literate-config-system)
  #:use-module (srfi srfi-1)
  #:use-module (guix packages)
  #:use-module (gnu packages emacs-xyz)
  #:export (literate-config-system make-lcs-config lcs-config?))

;; ════════════════════════════════════════════════════════════════════════════
;; § METADATA RECORD
;; ════════════════════════════════════════════════════════════════════════════

;; Simple metadata structure for literate configs
;; Returns an association list instead of a record type
(define (make-lcs-config org-file version depends after built-in defer)
  "Create literate config metadata.
ORG-FILE: path to source .org file
VERSION: version string
DEPENDS: list of required packages
AFTER: list of packages to load after
BUILT-IN: #t if package is built-in
DEFER: #t if should defer loading"
  (list
    (cons 'org-file org-file)
    (cons 'version version)
    (cons 'depends depends)
    (cons 'after after)
    (cons 'built-in built-in)
    (cons 'defer defer)))

(define (lcs-config? obj)
  "Check if OBJ is a valid lcs-config metadata structure."
  (and (list? obj)
       (every pair? obj)
       (pair? (assoc 'org-file obj))
       (pair? (assoc 'version obj))))

;; ════════════════════════════════════════════════════════════════════════════
;; § LITERATE-CONFIG-SYSTEM PROVIDER
;; ════════════════════════════════════════════════════════════════════════════

;; The actual loader is the Elisp file in ~/.config/emacs/lisp/
;; It depends on: org, leaf, org-supertag, org-roam
;; We re-export org and org-roam to ensure deps are in system
(define-public literate-config-system
  (let ((base emacs-org))
    (package
      (inherit base)
      (name "emacs-literate-config-system")
      (version "5.4.0")
      (synopsis "Guix-native literate configuration loader with org-roam integration")
      (description "Literate configuration system for Emacs using org-mode files.
Integrates with org-supertag for hierarchical package tagging and org-roam for
note-taking and knowledge management of loaded packages.")
      (propagated-inputs
        (modify-inputs (package-propagated-inputs base)
          (prepend emacs-org-roam))))))
