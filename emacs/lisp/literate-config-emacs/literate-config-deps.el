;;; literate-config-deps.el --- Dependency resolution -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:
;; Smart dependency detection and resolution for package configurations.

;;; Code:

(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § DEPENDENCY RULES
;; ════════════════════════════════════════════════════════════════════

(defconst literate-config-deps--rules
  ' ("lsp-ui" . ("lsp-mode"))
    ("lsp-treemacs" . ("lsp-mode" "treemacs"))
    ("company-lsp" . ("company" "lsp-mode"))
    ("helm-lsp" . ("helm" "lsp-mode"))
    ("ivy-lsp" . ("ivy" "lsp-mode"))
    ("org-superstar" . ("org"))
    ("org-roam" . ("org"))
    ("org-bullets" . ("org"))
    ("org-modern" . ("org"))
    ("magit-forge" . ("magit"))
    ("magit-todos" . ("magit"))
    ("treemacs-evil" . ("treemacs" "evil"))
    ("treemacs-projectile" . ("treemacs" "projectile"))
    ("counsel-projectile" . ("counsel" "projectile"))
    ("helm-projectile" . ("helm" "projectile")))
  "Explicit dependency rules.")

;; ════════════════════════════════════════════════════════════════════
;; § DEPENDENCY DETECTION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-deps--guess-dependencies (package-name)
  "Guess dependencies for PACKAGE-NAME using rules and patterns."
  (or (alist-get package-name literate-config-deps--rules 
                 nil nil #'string=)
      (let ((deps '()))
        (when (string-match "^evil-" package-name) 
          (push "evil" deps))
        (when (string-match "^org-" package-name) 
          (push "org" deps))
        (when (string-match "^magit-" package-name) 
          (push "magit" deps))
        (when (string-match "^lsp-" package-name) 
          (push "lsp-mode" deps))
        (when (string-match "^company-" package-name) 
          (push "company" deps))
        (when (string-match "^helm-" package-name) 
          (push "helm" deps))
        (when (string-match "^ivy-" package-name) 
          (push "ivy" deps))
        (when (string-match "^counsel-" package-name) 
          (push "counsel" deps))
        (nreverse deps))))

(defun literate-config-deps--resolve-dependencies (package-name)
  "Recursively resolve all dependencies for PACKAGE-NAME."
  (let ((deps (literate-config-deps--guess-dependencies package-name))
        (all-deps '()))
    (dolist (dep deps)
      (unless (member dep all-deps)
        (push dep all-deps)
        (dolist (sub-dep (literate-config-deps--resolve-dependencies dep))
          (unless (member sub-dep all-deps)
            (push sub-dep all-deps)))))
    (nreverse all-deps)))

(provide 'literate-config-deps)
;;; literate-config-deps.el ends here
