;;; literate-config-emacs.el --- Literate configuration system for Emacs -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 4.1.0
;; Package-Requires: ((emacs "26.1") (org "9.0") (straight "0") (leaf "0"))
;; Keywords: convenience, org, config

;;; Commentary:
;; Core system for managing Emacs configuration through org-mode files
;; with version enforcement and universal git support.
;;
;; Features:
;; - Org-based package configurations with :init: and implicit :config:
;; - Version tracking and enforcement
;; - Straight.el and leaf integration
;; - Universal git host support (GitHub, GitLab, Codeberg, etc.)

;;; Code:

(require 'org)
(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § CONFIGURATION
;; ════════════════════════════════════════════════════════════════════

(defgroup literate-config-emacs nil
  "Literate configuration system for Emacs."
  :group 'org
  :prefix "literate-config-emacs-")

(defcustom literate-config-emacs-org-directory
  (expand-file-name "Literative Configurations/" user-emacs-directory)
  "Directory containing literate package configuration files."
  :type 'directory
  :group 'literate-config-emacs)

(defcustom literate-config-emacs-use-leaf t
  "Use leaf for package configuration."
  :type 'boolean
  :group 'literate-config-emacs)

(defcustom literate-config-enforce-versions t
  "Enforce version matching between config files and installed packages.
When nil, version mismatches produce warnings instead of errors."
  :type 'boolean
  :group 'literate-config-emacs)

;; ════════════════════════════════════════════════════════════════════
;; § CORE FUNCTIONS
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-emacs--extract-properties (file)
  "Extract package properties from org FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (goto-char (point-min))
    (when (re-search-forward "^\\*+ " nil t)
      (let ((props (org-entry-properties)))
        (list :package (alist-get "PACKAGE" props nil nil #'string=)
              :straight (alist-get "STRAIGHT" props nil nil #'string=)
              :after (alist-get "AFTER" props nil nil #'string=)
              :category (alist-get "CATEGORY" props nil nil #'string=)
              :lazy (alist-get "LAZY" props nil nil #'string=)
              :version (alist-get "VERSION" props nil nil #'string=)
              :enforce-version (alist-get "ENFORCE-VERSION" props nil nil #'string=)
              :built-in (alist-get "BUILT-IN" props nil nil #'string=))))))

(defun literate-config-emacs--tangle-blocks (file tangle-type)
  "Extract and concatenate code blocks from FILE with TANGLE-TYPE.
TANGLE-TYPE can be 'init' or 'config'."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((code-blocks '()))
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (headline)
          (let* ((props (org-element-property :TANGLE headline))
                 (should-tangle
                  (cond
                   ;; Explicit :tangle: init
                   ((and (eq tangle-type 'init)
                         (string= props "init"))
                    t)
                   ;; Explicit :tangle: config or no tangle property (default to config)
                   ((and (eq tangle-type 'config)
                         (or (string= props "config")
                             (and (not props)
                                  (not (string= (org-element-property :TANGLE headline) "no")))))
                    t)
                   ;; Explicit :tangle: no - skip
                   ((string= props "no")
                    nil)
                   (t nil))))
            (when should-tangle
              (org-element-map headline 'src-block
                (lambda (src)
                  (push (org-element-property :value src) code-blocks)))))))
      (mapconcat #'identity (nreverse code-blocks) "\n\n"))))

(defun literate-config-emacs--generate-leaf (props init-code config-code)
  "Generate leaf declaration from PROPS, INIT-CODE, and CONFIG-CODE."
  (let* ((package (plist-get props :package))
         (straight-spec (plist-get props :straight))
         (after (plist-get props :after))
         (lazy (plist-get props :lazy)))
    (concat
     (format "(leaf %s\n" package)
     (format "  :straight %s\n" (or straight-spec "t"))
     (when after
       (format "  :after %s\n" after))
     (when lazy
       (format "  :defer t\n"))
     (when (and init-code (not (string-empty-p init-code)))
       (format "  :init\n%s\n" (mapconcat (lambda (line) (concat "  " line))
                                           (split-string init-code "\n")
                                           "\n")))
     (when (and config-code (not (string-empty-p config-code)))
       (format "  :config\n%s\n" (mapconcat (lambda (line) (concat "  " line))
                                             (split-string config-code "\n")
                                             "\n")))
     ")\n")))

(defun literate-config-emacs--should-check-version (props)
  "Determine if version check should be performed for package PROPS."
  (let ((config-version (plist-get props :version))
        (enforce (plist-get props :enforce-version))
        (built-in (plist-get props :built-in))
        (straight-spec (plist-get props :straight)))
    
    (and
     ;; Has version property
     config-version
     
     ;; Not built-in
     (not (string= built-in "t"))
     
     ;; Not local repo
     (not (and straight-spec (string-match-p ":local-repo" straight-spec)))
     
     ;; Not explicitly disabled for this package
     (not (string= enforce "nil"))
     
     ;; Global enforcement enabled OR explicitly enabled for this package
     (or literate-config-enforce-versions
         (string= enforce "t")))))

(defun literate-config-emacs--load-file (file)
  "Load a single org configuration FILE with version checking."
  (condition-case err
      (let* ((props (literate-config-emacs--extract-properties file))
             (package (plist-get props :package)))
        
        (when package
          ;; Perform version check if needed
          (when (literate-config-emacs--should-check-version props)
            (require 'literate-config-version)
            (literate-config-version-check-and-handle package props file))
          
          ;; Load package configuration
          (let ((init-code (literate-config-emacs--tangle-blocks file 'init))
                (config-code (literate-config-emacs--tangle-blocks file 'config)))
            
            (if literate-config-emacs-use-leaf
                ;; Generate and eval leaf form
                (let ((leaf-form (literate-config-emacs--generate-leaf props init-code config-code)))
                  (eval (read leaf-form)))
              ;; Fallback to direct evaluation
              (when init-code (eval (read init-code)))
              (when config-code (eval (read config-code)))))))
    (error
     (message "Error loading %s: %s" file (error-message-string err))
     (push (cons (file-name-nondirectory file) err) literate-config-emacs--load-errors))))

(defvar literate-config-emacs--load-errors nil
  "List of errors encountered during package loading.")

(defun literate-config-emacs-load-all ()
  "Load all org configuration files."
  (interactive)
  (setq literate-config-emacs--load-errors nil)
  (let ((files (directory-files-recursively 
                literate-config-emacs-org-directory
                "^[^#.].*\\.org$")))
    (dolist (file (sort files #'string<))
      (message "Loading %s..." (file-name-nondirectory file))
      (literate-config-emacs--load-file file))))

(defun literate-config-emacs-enable ()
  "Enable literate configuration system."
  (when (file-exists-p literate-config-emacs-org-directory)
    (literate-config-emacs-load-all)))

(provide 'literate-config-emacs)
;;; literate-config-emacs.el ends here
