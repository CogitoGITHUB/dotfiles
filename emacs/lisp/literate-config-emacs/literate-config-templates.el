;;; literate-config-templates.el --- Template generation -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:
;; Template generation for new package configurations with version detection.

;;; Code:

(require 'literate-config-deps)
(require 'literate-config-version)

;; ════════════════════════════════════════════════════════════════════
;; § GITHUB URL PARSER
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-templates--parse-github-url (url)
  "Parse GitHub URL and extract user/repo.
Returns (package-name . user/repo) or nil if invalid."
  (when (stringp url)
    (let ((clean-url (string-trim url)))
      (cond
       ;; Full GitHub URL
       ((string-match "https?://github\\.com/\\([^/]+\\)/\\([^/\n]+?\\)\\(?:\\.git\\)?/?$" clean-url)
        (let* ((user (match-string 1 clean-url))
               (repo (match-string 2 clean-url))
               (package-name (replace-regexp-in-string "\\.el$" "" repo)))
          (cons package-name (format "%s/%s" user repo))))
       
       ;; user/repo format
       ((string-match "^\\([^/]+\\)/\\([^/\n]+\\)$" clean-url)
        (let* ((user (match-string 1 clean-url))
               (repo (match-string 2 clean-url))
               (package-name (replace-regexp-in-string "\\.el$" "" repo)))
          (cons package-name (format "%s/%s" user repo))))
       
       ;; Just package name
       ((string-match "^[a-zA-Z0-9-]+$" clean-url)
        (cons clean-url nil))
       
       (t nil)))))

;; ════════════════════════════════════════════════════════════════════
;; § TEMPLATE GENERATION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-templates--generate-straight-spec (package-name repo-path)
  "Generate straight.el spec for PACKAGE-NAME and REPO-PATH."
  (if repo-path
      (format "(%s :type git :host github :repo \"%s\")" package-name repo-path)
    package-name))

(defun literate-config-templates--generate (package-name repo-path dependencies category version)
  "Generate org template for PACKAGE-NAME.
REPO-PATH: GitHub user/repo path
DEPENDENCIES: list of dependency package names
CATEGORY: package category
VERSION: detected version string"
  (let* ((pkg-upper (upcase package-name))
         (desc (capitalize (replace-regexp-in-string "-" " " package-name)))
         (straight-spec (literate-config-templates--generate-straight-spec package-name repo-path))
         (after-clause (when dependencies
                        (mapconcat #'identity dependencies " "))))
    
    (concat
     (format "* %s — %s\n" pkg-upper desc)
     ":PROPERTIES:\n"
     (format ":PACKAGE:  %s\n" package-name)
     (format ":STRAIGHT: %s\n" straight-spec)
     (when after-clause
       (format ":AFTER:    %s\n" after-clause))
     (when category
       (format ":CATEGORY: %s\n" category))
     (when version
       (format ":VERSION:  %s\n" version))
     ":END:\n\n"
     
     "** Description\n"
     ":PROPERTIES:\n"
     ":tangle: no\n"
     ":END:\n\n"
     (format "%s configuration for Emacs.\n\n" desc)
     (when repo-path
       (format "Repository: [[https://github.com/%s][GitHub]]\n\n" repo-path))
     (when version
       (format "Version: %s\n\n" version))
     
     "** Initialization\n"
     ":PROPERTIES:\n"
     ":tangle: init\n"
     ":END:\n\n"
     "#+begin_src emacs-lisp\n"
     ";; ════════════════════════════════════════════════════════════\n"
     (format ";; § %s — INITIALIZATION\n" pkg-upper)
     ";; ════════════════════════════════════════════════════════════\n\n"
     (format "(require '%s)\n\n" package-name)
     "#+end_src\n\n"
     
     "** Configuration\n\n"
     "#+begin_src emacs-lisp\n"
     ";; ════════════════════════════════════════════════════════════\n"
     (format ";; § %s — CONFIGURATION\n" pkg-upper)
     ";; ════════════════════════════════════════════════════════════\n\n"
     ";; Add configuration here\n\n"
     "#+end_src\n\n"
     
     "** Keybindings\n\n"
     "#+begin_src emacs-lisp\n"
     ";; ════════════════════════════════════════════════════════════\n"
     (format ";; § %s — KEYBINDINGS\n" pkg-upper)
     ";; ════════════════════════════════════════════════════════════\n\n"
     ";; Add keybindings here\n\n"
     "#+end_src\n\n"
     
     "** Performance Notes\n"
     ":PROPERTIES:\n"
     ":tangle: no\n"
     ":END:\n\n"
     "Startup time will be tracked automatically.\n\n")))

(provide 'literate-config-templates)
;;; literate-config-templates.el ends here
