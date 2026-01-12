;;; literate-config-loader.el --- Literate configuration system loader -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 4.1.0
;; Package-Requires: ((emacs "26.1") (org "9.0") (straight "0") (leaf "0"))
;; Keywords: convenience, org, config

;;; Commentary:
;; Main loader for the Literate Configuration System v4.1
;;
;; This is the single file you need to load in your init.el:
;;   (load "/path/to/literate-config-loader.el")
;;   (literate-config-initialize)
;;
;; Features:
;; - Org-based package configurations with :tangle: properties
;; - Version enforcement with universal git support
;; - Auto-display dashboard on startup
;; - Interactive package creation and management
;; - Smart dependency resolution
;; - Performance profiling

;;; Code:

;; ════════════════════════════════════════════════════════════════════
;; § SYSTEM PATH SETUP
;; ════════════════════════════════════════════════════════════════════

(defconst literate-config-system-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing literate config system files.")

(add-to-list 'load-path literate-config-system-directory)

;; ════════════════════════════════════════════════════════════════════
;; § LOAD MODULES
;; ════════════════════════════════════════════════════════════════════

(require 'literate-config-emacs)
(require 'literate-config-version)
(require 'literate-config-scanner)
(require 'literate-config-deps)
(require 'literate-config-templates)
(require 'literate-config-creator)

;; ════════════════════════════════════════════════════════════════════
;; § INITIALIZATION
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defun literate-config-initialize ()
  "Initialize the literate config system.
This should be called from your init.el after loading this file."
  (interactive)
  
  ;; Ensure org directory exists
  (unless (file-exists-p literate-config-emacs-org-directory)
    (make-directory literate-config-emacs-org-directory t)
    (message "Created literate config directory: %s" literate-config-emacs-org-directory))
  
  ;; Load all package configurations
  (message "Loading literate configurations...")
  (literate-config-emacs-enable)
  
   (message "Literate Config System v4.1 initialized"))

;; ════════════════════════════════════════════════════════════════════
;; § CONVENIENCE ALIASES
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defalias 'literate-config-new-package 'literate-config-create-package
  "Create a new package configuration.")

;;;###autoload
(defalias 'literate-config-edit 'literate-config-edit-package
  "Edit an existing package configuration.")

;;;###autoload
(defalias 'literate-config-update-version 'literate-config-update-package-version
  "Update package version.")

;; ════════════════════════════════════════════════════════════════════
;; § QUICK START GUIDE
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defun literate-config-help ()
  "Display quick start guide for Literate Config System."
  (interactive)
  (with-current-buffer (get-buffer-create "*Literate Config Help*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "═══════════════════════════════════════════════════════════════════════\n")
      (insert "  LITERATE CONFIG SYSTEM v4.1 — Quick Start Guide\n")
      (insert "═══════════════════════════════════════════════════════════════════════\n\n")
      
      (insert "SETUP\n")
      (insert "─────\n")
      (insert "Add to your init.el:\n\n")
      (insert "  (load \"/path/to/literate-config-loader.el\")\n")
      (insert "  (literate-config-initialize)\n\n")
      
      (insert "CONFIGURATION\n")
      (insert "─────────────\n")
      (insert "Directory: " literate-config-emacs-org-directory "\n")
      (insert "Version enforcement: " (if literate-config-enforce-versions "enabled" "disabled") "\n")
      (insert "Use leaf: " (if literate-config-emacs-use-leaf "yes" "no") "\n\n")
      
      (insert "COMMANDS\n")
      (insert "────────\n")
      (insert "M-x literate-config-new-package    Create new package config\n")
      (insert "M-x literate-config-edit           Edit existing package\n")
      (insert "M-x literate-config-show           Show dashboard\n")
      (insert "M-x literate-config-update-version Update package version\n\n")
      
      (insert "DASHBOARD KEYS\n")
      (insert "──────────────\n")
      (insert "RET   Open package file\n")
      (insert "r     Refresh dashboard\n")
      (insert "u     Update version for package at point\n")
      (insert "U     Update all outdated packages\n")
      (insert "c     Show changelog for package at point\n")
      (insert "p     Show profiling information\n")
      (insert "q     Quit dashboard\n\n")
      
      (insert "PACKAGE FILE STRUCTURE\n")
      (insert "──────────────────────\n")
      (insert "* Package-Name\n")
      (insert ":PROPERTIES:\n")
      (insert ":PACKAGE:  package-name\n")
      (insert ":STRAIGHT: (package-name :type git :host github :repo \"user/repo\")\n")
      (insert ":VERSION:  v1.0.0\n")
      (insert ":END:\n\n")
      (insert "** Description\n")
      (insert ":PROPERTIES:\n")
      (insert ":tangle: no        ← Not included in config\n")
      (insert ":END:\n\n")
      (insert "** Initialization\n")
      (insert ":PROPERTIES:\n")
      (insert ":tangle: init      ← Goes to :init section\n")
      (insert ":END:\n")
      (insert "#+begin_src emacs-lisp\n")
      (insert "(require 'package-name)\n")
      (insert "#+end_src\n\n")
      (insert "** Configuration    ← Implicit :config (no property needed)\n")
      (insert "#+begin_src emacs-lisp\n")
      (insert "(setq package-var 'value)\n")
      (insert "#+end_src\n\n")
      
      (insert "VERSION ENFORCEMENT\n")
      (insert "───────────────────\n")
      (insert "• Each package tracks its version via :VERSION: property\n")
      (insert "• On load, installed version is checked against config version\n")
      (insert "• Mismatch causes error (if enforcement enabled)\n")
      (insert "• Use 'u' in dashboard to update versions\n")
      (insert "• Use :BUILT-IN: t for Emacs built-in packages\n")
      (insert "• Use :ENFORCE-VERSION: nil to skip check for specific package\n\n")
      
      (insert "CUSTOMIZATION\n")
      (insert "─────────────\n")
      (insert "M-x customize-group RET literate-config-emacs RET\n\n")
      
      (insert "═══════════════════════════════════════════════════════════════════════\n")
      (goto-char (point-min))
      (special-mode)
      (display-buffer (current-buffer)))))

;; ════════════════════════════════════════════════════════════════════
;; § PROVIDE
;; ════════════════════════════════════════════════════════════════════

(provide 'literate-config-loader)

;;; literate-config-loader.el ends here
