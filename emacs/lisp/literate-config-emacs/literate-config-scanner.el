;;; literate-config-scanner.el --- Package scanning and database -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1") (org "9.0"))

;;; Code:

(require 'org)
(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § DATA STRUCTURES
;; ════════════════════════════════════════════════════════════════════

(defvar literate-config-scanner--packages nil
  "Alist of package info: (name . plist).")

(defvar literate-config-scanner--startup-times nil
  "Alist of (package . milliseconds).")

;; ════════════════════════════════════════════════════════════════════
;; § CATEGORY DETECTION
;; ════════════════════════════════════════════════════════════════════

(defcustom literate-config-scanner-categories
  '(("core" . ("evil" "org" "leaf" "straight"))
    ("ui" . ("doom-themes" "doom-modeline" "all-the-icons" "dashboard"))
    ("completion" . ("company" "ivy" "counsel" "helm" "vertico"))
    ("lang" . ("lsp-mode" "eglot" "tree-sitter"))
    ("utils" . ("which-key" "helpful" "magit" "projectile")))
  "Package categories for organization."
  :type '(alist :key-type string :value-type (repeat string))
  :group 'literate-config-emacs)

(defun literate-config-scanner--detect-category (package-name)
  "Detect category for PACKAGE-NAME."
  (or (cl-loop for (category . packages) in literate-config-scanner-categories
               when (member package-name packages)
               return category)
      (cond
       ((string-match-p "theme\\|color\\|icon\\|modeline\\|dashboard" package-name) "ui")
       ((string-match-p "lsp\\|lang\\|eglot\\|tree-sitter" package-name) "lang")
       ((string-match-p "company\\|ivy\\|helm\\|vertico\\|corfu" package-name) "completion")
       ((string-match-p "evil\\|org\\|leaf" package-name) "core")
       (t "utils"))))

;; ════════════════════════════════════════════════════════════════════
;; § PACKAGE SCANNING
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-scanner--extract-properties (file)
  "Extract package properties from org FILE."
  (condition-case err
      (with-temp-buffer
        (insert-file-contents file)
        (org-mode)
        (goto-char (point-min))
        (when (re-search-forward "^\\*+ " nil t)
          (let ((props (org-entry-properties)))
            (list :file file
                  :package (alist-get "PACKAGE" props nil nil #'string=)
                  :straight (alist-get "STRAIGHT" props nil nil #'string=)
                  :after (alist-get "AFTER" props nil nil #'string=)
                  :category (alist-get "CATEGORY" props nil nil #'string=)
                  :lazy (alist-get "LAZY" props nil nil #'string=)
                  :status 'unknown))))
    (error
     (message "Error scanning %s: %s" file (error-message-string err))
     nil)))

(defun literate-config-scanner-scan-all ()
  "Scan all package .org files and populate package database."
  (setq literate-config-scanner--packages nil)
  (let ((files (directory-files-recursively 
                literate-config-emacs-org-directory
                "^[^#.].*\\.org$")))
    (dolist (file files)
      (when-let* ((props (literate-config-scanner--extract-properties file))
                  (package (plist-get props :package)))
        (push (cons package props) literate-config-scanner--packages)))))

;; ════════════════════════════════════════════════════════════════════
;; § PROFILING
;; ════════════════════════════════════════════════════════════════════

(defmacro literate-config-scanner--with-profiling (package-name &rest body)
  "Execute BODY and record time for PACKAGE-NAME."
  (declare (indent 1))
  `(let ((start-time (current-time)))
     (prog1 (progn ,@body)
       (let ((elapsed (float-time (time-subtract (current-time) start-time))))
         (push (cons ,package-name (* elapsed 1000)) 
               literate-config-scanner--startup-times)))))

(defun literate-config-scanner--format-time (ms)
  "Format milliseconds MS for display."
  (cond
   ((< ms 1) (format "%.2fμs" (* ms 1000)))
   ((< ms 1000) (format "%.1fms" ms))
   (t (format "%.2fs" (/ ms 1000)))))

(provide 'literate-config-scanner)
;;; literate-config-scanner.el ends here
