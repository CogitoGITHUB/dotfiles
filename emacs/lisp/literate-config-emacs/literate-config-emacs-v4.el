;;; literate-config-emacs-v4.el --- Literate configuration system v4 -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 4.0.0
;; Package-Requires: ((emacs "26.1") (org "9.0") (straight "0") (leaf "0"))
;; Keywords: convenience, org, config

;;; Commentary:
;; Modern literate configuration system for Emacs with:
;; - Straight.el and leaf integration
;; - Interactive dashboard
;; - Smart dependency resolution
;; - Category-based organization
;; - Performance profiling

;;; Code:

;; ════════════════════════════════════════════════════════════════════
;; § LOAD MODULES
;; ════════════════════════════════════════════════════════════════════

(require 'literate-config-emacs)
(require 'literate-config-scanner)
(require 'literate-config-deps)
(require 'literate-config-templates)
(require 'literate-config-creator)
(require 'literate-config-dashboard)

;; ════════════════════════════════════════════════════════════════════
;; § INITIALIZATION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-emacs-v4-initialize ()
  "Initialize the literate config system."
  (literate-config-scanner-scan-all))

;; Auto-initialize on load
(add-hook 'emacs-startup-hook #'literate-config-emacs-v4-initialize)

(provide 'literate-config-emacs-v4)
;;; literate-config-emacs-v4.el ends here
