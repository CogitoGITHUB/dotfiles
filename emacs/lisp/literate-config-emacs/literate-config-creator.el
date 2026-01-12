;;; literate-config-creator.el --- Interactive package creator -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:
;; Interactive commands for creating and editing package configurations.

;;; Code:

(require 'literate-config-templates)
(require 'literate-config-deps)
(require 'literate-config-scanner)
(require 'literate-config-version)

;; ════════════════════════════════════════════════════════════════════
;; § CONFIGURATION
;; ════════════════════════════════════════════════════════════════════

(defcustom literate-config-creator-split-by-category t
  "Organize packages into category subdirectories."
  :type 'boolean
  :group 'literate-config-emacs)

;; ════════════════════════════════════════════════════════════════════
;; § FILE CREATION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-creator--get-file-path (package-name category)
  "Get file path for PACKAGE-NAME in CATEGORY."
  (let ((subdir (if literate-config-creator-split-by-category
                   (expand-file-name category literate-config-emacs-org-directory)
                 literate-config-emacs-org-directory)))
    (unless (file-exists-p subdir)
      (make-directory subdir t))
    (expand-file-name (concat package-name ".org") subdir)))

(defun literate-config-creator--create-file (package-name content category)
  "Create file for PACKAGE-NAME with CONTENT in CATEGORY."
  (let ((filepath (literate-config-creator--get-file-path package-name category)))
    (when (file-exists-p filepath)
      (unless (y-or-n-p (format "File %s exists. Overwrite? " package-name))
        (user-error "Aborted")))
    (with-temp-file filepath
      (insert content))
    filepath))

;; ════════════════════════════════════════════════════════════════════
;; § INTERACTIVE COMMANDS
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defun literate-config-create-package ()
  "Create a new package configuration interactively."
  (interactive)
  
  (unless (file-exists-p literate-config-emacs-org-directory)
    (make-directory literate-config-emacs-org-directory t))
  
  ;; Get package info
  (let* ((input (read-string "GitHub URL or package name: "))
         (parsed (literate-config-templates--parse-github-url input)))
    
    (unless parsed
      (if (y-or-n-p "Invalid input. Try again? ")
          (literate-config-create-package)
        (user-error "Aborted")))
    
    (when parsed
      (let* ((package-name (car parsed))
             (repo-path (cdr parsed))
             (category (literate-config-scanner--detect-category package-name))
             
             ;; Generate straight spec for version detection
             (straight-spec (literate-config-templates--generate-straight-spec 
                             package-name repo-path))
             
             ;; Detect version
             (detected-version (literate-config-version--detect-for-new-package 
                                package-name straight-spec))
             (version (if detected-version
                          (if (y-or-n-p (format "Detected version: %s. Use this? " detected-version))
                              detected-version
                            (read-string "Version (e.g., v1.0.0): " "v"))
                        (read-string "Version (e.g., v1.0.0): " "v")))
             
             ;; Get dependencies
             (guessed-deps (literate-config-deps--resolve-dependencies package-name))
             (deps-prompt (if guessed-deps
                             (format "Dependencies (auto-detected: %s): " 
                                     (mapconcat #'identity guessed-deps ", "))
                           "Dependencies (space-separated): "))
             (deps-input (read-string deps-prompt 
                                      (when guessed-deps 
                                        (mapconcat #'identity guessed-deps " "))))
             (dependencies (when (not (string-empty-p deps-input))
                            (split-string deps-input)))
             
             ;; Generate template
             (content (literate-config-templates--generate 
                      package-name repo-path dependencies category version))
             
             ;; Create file
             (filepath (literate-config-creator--create-file 
                       package-name content category)))
        
        ;; Open file
        (find-file filepath)
        (org-mode)
        (message "Created %s in %s with version %s" package-name category version)))))

;;;###autoload
(defun literate-config-create-package-from-name (package-name)
  "Quick create from PACKAGE-NAME without prompts."
  (interactive "sPackage name: ")
  (let* ((repo-path nil)
         (dependencies (literate-config-deps--resolve-dependencies package-name))
         (category (literate-config-scanner--detect-category package-name))
         (version (read-string (format "Version for %s (e.g., v1.0.0): " package-name) "v"))
         (content (literate-config-templates--generate 
                  package-name repo-path dependencies category version))
         (filepath (literate-config-creator--create-file 
                   package-name content category)))
    (find-file filepath)
    (org-mode)
    (message "Created %s" package-name)))

;;;###autoload
(defun literate-config-edit-package ()
  "Select and edit an existing package."
  (interactive)
  (literate-config-scanner-scan-all)
  (let* ((package-names (mapcar #'car literate-config-scanner--packages))
         (choice (completing-read "Edit package: " package-names nil t)))
    (when choice
      (let* ((pkg-info (assoc choice literate-config-scanner--packages))
             (file (plist-get (cdr pkg-info) :file)))
        (when file
          (find-file file))))))

(provide 'literate-config-creator)
;;; literate-config-creator.el ends here
