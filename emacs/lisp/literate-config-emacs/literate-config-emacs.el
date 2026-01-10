;;; literate-config-emacs.el --- Literate configuration system for Emacs -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 4.0.0
;; Package-Requires: ((emacs "26.1") (org "9.0") (straight "0") (leaf "0"))
;; Keywords: convenience, org, config

;;; Commentary:
;; Core system for managing Emacs configuration through org-mode files
;; Integrates with straight.el and leaf for package management

;;; Code:

(require 'org)
(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § CONFIGURATION
;; ════════════════════════════════════════════════════════════════════

(defgroup literate-config-emacs nil
  "Literate configuration system for Emacs."
  :group 'org
  :prefix "literate-config-emacs")

(defcustom literate-config-emacs-org-directory
  (expand-file-name "Literative Configurations/" user-emacs-directory)
  "Directory containing literate package configuration files."
  :type 'directory
  :group 'literate-config-emacs)

(defcustom literate-config-emacs-use-leaf t
  "Use leaf for package configuration."
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
      (let* ((element (org-element-at-point)))
        (list :package (org-element-property :PACKAGE element)
              :straight (org-element-property :STRAIGHT element)
              :after (org-element-property :AFTER element)
              :category (org-element-property :CATEGORY element)
              :lazy (org-element-property :LAZY element)
              :init-tag (when (member "init" (org-element-property :tags element)) t)
              :config-tag (when (member "config" (org-element-property :tags element)) t))))))

(defun literate-config-emacs--tangle-blocks (file tag)
  "Extract and concatenate code blocks from FILE with TAG."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((code-blocks '()))
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (headline)
          (when (member tag (org-element-property :tags headline))
            (org-element-map headline 'src-block
              (lambda (src)
                (push (org-element-property :value src) code-blocks))))))
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

(defun literate-config-emacs--load-file (file)
  "Load a single org configuration FILE."
  (condition-case err
      (let* ((props (literate-config-emacs--extract-properties file))
             (package (plist-get props :package))
             (init-code (literate-config-emacs--tangle-blocks file "init"))
             (config-code (literate-config-emacs--tangle-blocks file "config")))
        
        (when package
          (if literate-config-emacs-use-leaf
              ;; Generate and eval leaf form
              (let ((leaf-form (literate-config-emacs--generate-leaf props init-code config-code)))
                (eval (read leaf-form)))
            ;; Fallback to direct evaluation
            (when init-code (eval (read init-code)))
            (when config-code (eval (read config-code))))))
    (error
     (message "Error loading %s: %s" file (error-message-string err)))))

(defun literate-config-emacs-load-all ()
  "Load all org configuration files."
  (interactive)
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
