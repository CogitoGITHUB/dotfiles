;;it needs to make the code for require and load the package also i dont want any message exept all good or error if something went wrong nothing else !!!


;;; literate-config-system.el --- Complete Literate Configuration System -*- lexical-binding: t -*-
;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 4.3.0
;; Package-Requires: ((emacs "26.1") (org "9.0") (straight "0") (leaf "0"))
;; Keywords: convenience, org, config
;; ═══════════════════════════════════════════════════════════════════
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
(defcustom literate-config-creator-split-by-category t
  "Organize packages into category subdirectories."
  :type 'boolean
  :group 'literate-config-emacs)
(defcustom literate-config-scanner-categories
  '(("core" . ("evil" "org" "leaf" "straight"))
    ("ui" . ("doom-themes" "doom-modeline" "all-the-icons" "dashboard"))
    ("completion" . ("company" "ivy" "counsel" "helm" "vertico"))
    ("lang" . ("lsp-mode" "eglot" "tree-sitter"))
    ("utils" . ("which-key" "helpful" "magit" "projectile")))
  "Package categories for organization."
  :type '(alist :key-type string :value-type (repeat string))
  :group 'literate-config-emacs)
;; ════════════════════════════════════════════════════════════════════
;; § DATA STRUCTURES
;; ════════════════════════════════════════════════════════════════════
(defvar literate-config-scanner--packages nil
  "List of all scanned packages. Each entry is (name . properties).")
(defvar literate-config-scanner--startup-times nil
  "List of package load times in milliseconds.")
(defvar literate-config-emacs--load-errors nil
  "List of errors encountered during package loading.")
(defvar literate-config-version--mismatches nil
  "List of version mismatches found during loading.")
(defvar literate-config--file-watch-descriptor nil
  "File watch descriptor for the literate config directory.")
(defvar literate-config--reload-timer nil
  "Timer for debounced reloading.")
(defvar literate-config--auto-reload-enabled t
  "Whether auto-reload on file save is enabled.")
;; ════════════════════════════════════════════════════════════════════
;; § DEPENDENCY RULES
;; ════════════════════════════════════════════════════════════════════
(defconst literate-config-deps--rules
  '(("lsp-ui" . ("lsp-mode"))
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
  "Known package dependencies.")
;; ════════════════════════════════════════════════════════════════════
;; § HELPER FUNCTIONS
;; ════════════════════════════════════════════════════════════════════
(defun literate-config-deps--guess-dependencies (package-name)
  "Guess dependencies for PACKAGE-NAME using rules and patterns."
  (or (cdr (assoc package-name literate-config-deps--rules))
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
  "Find all dependencies for PACKAGE-NAME recursively."
  (let ((deps (literate-config-deps--guess-dependencies package-name))
        (all-deps '()))
    (dolist (dep deps)
      (unless (member dep all-deps)
        (push dep all-deps)
        (dolist (sub-dep (literate-config-deps--resolve-dependencies dep))
          (unless (member sub-dep all-deps)
            (push sub-dep all-deps)))))
    (nreverse all-deps)))
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
;; § VERSION DETECTION
;; ════════════════════════════════════════════════════════════════════
(defun literate-config-version--get-installed (package-name)
  "Get installed version for PACKAGE-NAME from git repo."
  (unless (fboundp 'straight--repos-dir)
    (error "straight.el not loaded - cannot check package versions"))
  (let* ((repo-dir (straight--repos-dir package-name)))
    (when (and repo-dir (file-exists-p repo-dir))
      (let ((default-directory repo-dir))
        (let ((version (string-trim
                        (shell-command-to-string 
                         "git describe --tags --abbrev=0 2>/dev/null"))))
          (if (string-empty-p version)
              (string-trim (shell-command-to-string "git rev-parse --short HEAD"))
            version))))))
(defun literate-config-version--parse (version-string)
  "Parse VERSION-STRING like 'v1.15.0' into (1 15 0)."
  (when (and version-string 
             (string-match "^v?\\([0-9]+\\)\\.\\([0-9]+\\)\\.\\([0-9]+\\)" version-string))
    (list (string-to-number (match-string 1 version-string))
          (string-to-number (match-string 2 version-string))
          (string-to-number (match-string 3 version-string)))))
(defun literate-config-version--compare (v1 v2)
  "Compare versions V1 and V2."
  (let ((parsed-v1 (literate-config-version--parse v1))
        (parsed-v2 (literate-config-version--parse v2)))
    (cond
     ((and parsed-v1 parsed-v2)
      (cond ((equal parsed-v1 parsed-v2) 'equal)
            ((version-list-< parsed-v1 parsed-v2) 'less)
            (t 'greater)))
     ((string= v1 v2) 'equal)
     (t 'incomparable))))
;; ════════════════════════════════════════════════════════════════════
;; § TEMPLATE GENERATION
;; ════════════════════════════════════════════════════════════════════
(defun literate-config-templates--parse-github-url (url)
  "Parse GitHub URL and extract user/repo.
Returns (package-name . user/repo) or nil if invalid."
  (when (stringp url)
    (let ((clean-url (string-trim url)))
      (cond
       ((string-match "https?://github\\.com/\\([^/]+\\)/\\([^/\n]+?\\)\\(?:\\.git\\)?/?$" clean-url)
        (let* ((user (match-string 1 clean-url))
               (repo (match-string 2 clean-url))
               (package-name (replace-regexp-in-string "\\.el$" "" repo)))
          (cons package-name (format "%s/%s" user repo))))
       ((string-match "^\\([^/]+\\)/\\([^/\n]+\\)$" clean-url)
        (let* ((user (match-string 1 clean-url))
               (repo (match-string 2 clean-url))
               (package-name (replace-regexp-in-string "\\.el$" "" repo)))
          (cons package-name (format "%s/%s" user repo))))
       ((string-match "^[a-zA-Z0-9-]+$" clean-url)
        (cons clean-url nil))
       (t nil)))))
(defun literate-config-templates--generate-straight-spec (package-name repo-path)
  "Generate straight.el spec for PACKAGE-NAME and REPO-PATH."
  (if repo-path
      (format "(%s :type git :host github :repo \"%s\")" package-name repo-path)
    package-name))
(defun literate-config-templates--generate (package-name repo-path dependencies category version)
  "Generate org template for PACKAGE-NAME."
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
     
     "** Dependencies\n"
     ":PROPERTIES:\n"
     ":tangle: no\n"
     ":END:\n\n"
     "Optional dependencies that will be auto-installed:\n\n"
     "To add dependencies, add a DEPENDS property to the main heading:\n"
     "=:DEPENDS: package1 package2=\n\n"
     "Or for complex specs:\n"
     "=:DEPENDS: package1 (package2 :repo \"user/repo\")=\n\n"
     
     "** Initialization\n"
     ":PROPERTIES:\n"
     ":tangle: init\n"
     ":END:\n\n"
     "Code here goes in :init section (runs BEFORE package loads)\n\n"
     "#+begin_src emacs-lisp\n"
     ";; Pre-load configuration\n"
     "#+end_src\n\n"
     
     "** Configuration\n\n"
     "Code here goes in :config section (runs AFTER package loads)\n"
     "Note: No :tangle: property needed - this is the default!\n\n"
     "#+begin_src emacs-lisp\n"
     ";; Add your configuration here\n"
     "#+end_src\n\n"
     
     "** Keybindings\n\n"
     "#+begin_src emacs-lisp\n"
     ";; Add keybindings here\n"
     "#+end_src\n\n")))
;; ════════════════════════════════════════════════════════════════════
;; § CORE LOADING FUNCTIONS
;; ════════════════════════════════════════════════════════════════════
(defun literate-config-emacs--extract-properties (file)
  "Extract package properties from org FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (goto-char (point-min))
    (when (re-search-forward "^\\*+ " nil t)
      (let* ((props (org-entry-properties nil 'standard))
             ;; org-entry-properties returns alist like (("PACKAGE" . "avy") ...)
             (straight-raw (cdr (assoc "STRAIGHT" props)))
             ;; Convert straight string to proper value immediately
             (straight-value (when straight-raw
                              (condition-case nil
                                  (read straight-raw)
                                (error (intern straight-raw))))))
        (list :package (cdr (assoc "PACKAGE" props))
              :straight straight-value
              :after (cdr (assoc "AFTER" props))
              :depends (cdr (assoc "DEPENDS" props))
              :category (cdr (assoc "CATEGORY" props))
              :lazy (cdr (assoc "LAZY" props))
              :version (cdr (assoc "VERSION" props))
              :enforce-version (cdr (assoc "ENFORCE-VERSION" props))
              :built-in (cdr (assoc "BUILT-IN" props)))))))
(defun literate-config-emacs--tangle-blocks (file tangle-type)
  "Extract code blocks from FILE with TANGLE-TYPE ('init or 'config)."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((code-blocks '()))
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (headline)
          (let* ((props (org-element-property :TANGLE headline))
                 (should-tangle
                  (cond
                   ((and (eq tangle-type 'init) (string= props "init")) t)
                   ((and (eq tangle-type 'config)
                         (or (string= props "config")
                             (and (not props)
                                  (not (string= (org-element-property :TANGLE headline) "no")))))
                    t)
                   ((string= props "no") nil)
                   (t nil))))
            (when should-tangle
              (org-element-map headline 'src-block
                (lambda (src)
                  (push (org-element-property :value src) code-blocks)))))))
      (mapconcat #'identity (nreverse code-blocks) "\n\n"))))
(defun literate-config-emacs--generate-leaf (props init-code config-code)
  "Generate leaf declaration from PROPS, INIT-CODE, and CONFIG-CODE."
  (let* ((package (plist-get props :package))
         (straight-value (plist-get props :straight))  ; Already converted in extract-properties
         (after (plist-get props :after))
         (lazy (plist-get props :lazy)))
    
    ;; Build the leaf form as a proper s-expression
    (let ((leaf-form
           `(leaf ,(intern package)
              :straight ,(or straight-value t)
              ,@(when after 
                  (let ((after-list (split-string after)))
                    (if (= (length after-list) 1)
                        `(:after ,(intern (car after-list)))
                      `(:after ,(mapcar #'intern after-list)))))
              ,@(when lazy '(:defer t))
              ,@(when (and init-code (not (string-empty-p init-code)))
                  (condition-case err
                      `(:init ,(read (concat "(progn\n" init-code "\n)")))
                    (error 
                     (message "Error parsing init code for %s: %s" package (error-message-string err))
                     nil)))
              ,@(when (and config-code (not (string-empty-p config-code)))
                  (condition-case err
                      `(:config ,(read (concat "(progn\n" config-code "\n)")))
                    (error 
                     (message "Error parsing config code for %s: %s" package (error-message-string err))
                     nil))))))
      
      ;; Return the form itself
      leaf-form)))
(defun literate-config-emacs--should-check-version (props)
  "Check if version enforcement is needed for PROPS."
  (let ((config-version (plist-get props :version))
        (enforce (plist-get props :enforce-version))
        (built-in (plist-get props :built-in))
        (straight-spec (plist-get props :straight)))
    (and config-version
         (not (string= built-in "t"))
         ;; Check if straight-spec contains :local-repo (it's now a list, not string)
         (not (and (listp straight-spec) 
                   (memq :local-repo straight-spec)))
         (not (string= enforce "nil"))
         (or literate-config-enforce-versions (string= enforce "t")))))
(defun literate-config-version-check-and-handle (package-name props file)
  "Check version for PACKAGE-NAME with PROPS from FILE."
  (let* ((config-version (plist-get props :version))
         (installed-version (literate-config-version--get-installed package-name)))
    
    (unless installed-version
      (message "Warning: Cannot detect installed version for %s" package-name)
      (cl-return-from literate-config-version-check-and-handle nil))
    
    (let ((comparison (literate-config-version--compare config-version installed-version)))
      (pcase comparison
        ('equal nil)
        ('less
         (let ((msg (format "VERSION MISMATCH: %s\n  Config: %s\n  Installed: %s"
                            package-name config-version installed-version)))
           (if literate-config-enforce-versions
               (progn
                 (push (list :package package-name
                             :config-version config-version
                             :installed-version installed-version
                             :file file)
                       literate-config-version--mismatches)
                 (error msg))
             (message "Warning: %s" msg))))
        ('greater
         (message "Warning: Config version %s is NEWER than installed %s for %s" 
                  config-version installed-version package-name))
        ('incomparable
         (message "Info: Cannot compare versions for %s: config=%s installed=%s" 
                  package-name config-version installed-version))))))
(defun literate-config-emacs--load-file (file)
  "Load a single org configuration FILE with version checking.
Supports multiple packages in one file by processing all top-level headlines."
  (condition-case err
      (with-temp-buffer
        (insert-file-contents file)
        (org-mode)
        (goto-char (point-min))
        
        ;; Process each top-level headline as a potential package
        (while (re-search-forward "^\\* " nil t)
          (save-excursion
            (let* ((props (org-entry-properties nil 'standard))
                   (straight-raw (cdr (assoc "STRAIGHT" props)))
                   (straight-value (when straight-raw
                                    (condition-case nil
                                        (read straight-raw)
                                      (error (intern straight-raw)))))
                   (package-props (list :package (cdr (assoc "PACKAGE" props))
                                       :straight straight-value
                                       :after (cdr (assoc "AFTER" props))
                                       :depends (cdr (assoc "DEPENDS" props))
                                       :category (cdr (assoc "CATEGORY" props))
                                       :lazy (cdr (assoc "LAZY" props))
                                       :version (cdr (assoc "VERSION" props))
                                       :enforce-version (cdr (assoc "ENFORCE-VERSION" props))
                                       :built-in (cdr (assoc "BUILT-IN" props))))
                   (package (plist-get package-props :package)))
              
              (when package
                (when (literate-config-emacs--should-check-version package-props)
                  (literate-config-version-check-and-handle package package-props file))
                
                ;; Extract code blocks for this specific headline's subtree
                (let ((headline-start (point))
                      (headline-end (save-excursion
                                     (org-end-of-subtree t t)
                                     (point))))
                  (let ((init-code (literate-config-emacs--tangle-blocks-in-region 
                                   headline-start headline-end 'init))
                        (config-code (literate-config-emacs--tangle-blocks-in-region 
                                     headline-start headline-end 'config))
                        (depends (plist-get package-props :depends)))
                    
                    ;; Install dependencies first if specified
                    (when depends
                      (literate-config-emacs--install-dependencies depends))
                    
                    (if literate-config-emacs-use-leaf
                        (let ((leaf-form (literate-config-emacs--generate-leaf 
                                         package-props init-code config-code)))
                          (eval leaf-form t))
                      (when init-code (eval (read init-code) t))
                      (when config-code (eval (read config-code) t))))))))))
    (error
     (message "Error loading %s: %s" file (error-message-string err))
     (push (cons (file-name-nondirectory file) err) literate-config-emacs--load-errors))))

(defun literate-config-emacs--tangle-blocks-in-region (start end tangle-type)
  "Extract code blocks between START and END with TANGLE-TYPE ('init or 'config)."
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (let ((code-blocks '()))
        (org-element-map (org-element-parse-buffer) 'headline
          (lambda (headline)
            (let* ((props (org-element-property :TANGLE headline))
                   (should-tangle
                    (cond
                     ((and (eq tangle-type 'init) (string= props "init")) t)
                     ((and (eq tangle-type 'config)
                           (or (string= props "config")
                               (and (not props)
                                    (not (string= (org-element-property :TANGLE headline) "no")))))
                      t)
                     ((string= props "no") nil)
                     (t nil))))
              (when should-tangle
                (org-element-map headline 'src-block
                  (lambda (src)
                    (push (org-element-property :value src) code-blocks)))))))
        (mapconcat #'identity (nreverse code-blocks) "\n\n")))))

(defun literate-config-emacs--install-dependencies (depends-string)
  "Install dependencies specified in DEPENDS-STRING.
Format: 'package1 package2' or 'package1 (package2 :repo user/repo) package3'"
  (let ((deps (split-string depends-string)))
    (dolist (dep deps)
      (condition-case err
          (let ((dep-spec (if (string-prefix-p "(" dep)
                             ;; Complex spec like (package :repo "user/repo")
                             (read dep)
                           ;; Simple package name
                           (intern dep))))
            (message "Installing dependency: %s" dep)
            (if literate-config-emacs-use-leaf
                (eval `(leaf ,dep-spec :straight t) t)
              (straight-use-package dep-spec)))
        (error
         (message "Warning: Failed to install dependency %s: %s" 
                  dep (error-message-string err)))))))
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
;; ════════════════════════════════════════════════════════════════════
;; § AUTO-RELOAD FUNCTIONALITY
;; ════════════════════════════════════════════════════════════════════
(defun literate-config--reload-debounced ()
  "Reload configurations after a short delay (debounced)."
  (when literate-config--reload-timer
    (cancel-timer literate-config--reload-timer))
  (setq literate-config--reload-timer
        (run-with-timer 1 nil
                        (lambda ()
                          (message "Reloading literate configurations...")
                          (literate-config-emacs-load-all)
                          (message "Literate configurations reloaded!")))))

(defun literate-config--file-notify-callback (event)
  "Handle file notification EVENT for literate config directory."
  (when literate-config--auto-reload-enabled
    (let ((event-type (nth 1 event))
          (file (nth 2 event)))
      ;; Only reload on save/create/delete of .org files
      (when (and file
                 (string-match-p "\\.org$" file)
                 (not (string-match-p "^[.#]" (file-name-nondirectory file)))
                 (memq event-type '(created changed deleted renamed)))
        (message "Detected change in %s, reloading..." (file-name-nondirectory file))
        (literate-config--reload-debounced)))))

(defun literate-config-watch-enable ()
  "Enable file watching for auto-reload of literate configurations."
  (interactive)
  (when literate-config--file-watch-descriptor
    (file-notify-rm-watch literate-config--file-watch-descriptor)
    (setq literate-config--file-watch-descriptor nil))
  
  (when (file-exists-p literate-config-emacs-org-directory)
    (setq literate-config--file-watch-descriptor
          (file-notify-add-watch
           literate-config-emacs-org-directory
           '(change)
           #'literate-config--file-notify-callback))
    (setq literate-config--auto-reload-enabled t)
    (message "Literate config auto-reload enabled for: %s" 
             literate-config-emacs-org-directory)))

(defun literate-config-watch-disable ()
  "Disable file watching for auto-reload."
  (interactive)
  (when literate-config--file-watch-descriptor
    (file-notify-rm-watch literate-config--file-watch-descriptor)
    (setq literate-config--file-watch-descriptor nil))
  (setq literate-config--auto-reload-enabled nil)
  (message "Literate config auto-reload disabled"))

(defun literate-config-watch-toggle ()
  "Toggle auto-reload on/off."
  (interactive)
  (if literate-config--auto-reload-enabled
      (literate-config-watch-disable)
    (literate-config-watch-enable)))
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
             (straight-spec (literate-config-templates--generate-straight-spec 
                             package-name repo-path))
             (detected-version (literate-config-version--get-installed package-name))
             (version (if detected-version
                          (if (y-or-n-p (format "Detected version: %s. Use this? " detected-version))
                              detected-version
                            (read-string "Version (e.g., v1.0.0): " "v"))
                        (read-string "Version (e.g., v1.0.0): " "v")))
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
             (content (literate-config-templates--generate 
                      package-name repo-path dependencies category version))
             (filepath (literate-config-creator--create-file 
                       package-name content category)))
        
        (find-file filepath)
        (org-mode)
        (message "Created %s in %s with version %s" package-name category version)))))
;;;###autoload
(defun literate-config-initialize ()
  "Initialize the literate config system."
  (interactive)
  
  (unless (and (featurep 'straight) (fboundp 'straight--repos-dir))
    (message "Warning: straight.el not properly loaded - version checking disabled")
    (setq literate-config-enforce-versions nil))
  
  (unless (file-exists-p literate-config-emacs-org-directory)
    (make-directory literate-config-emacs-org-directory t)
    (message "Created literate config directory: %s" literate-config-emacs-org-directory))
  
  (message "Loading literate configurations...")
  (condition-case err
      (literate-config-emacs-enable)
    (error 
     (message "Error loading literate configurations: %s" (error-message-string err))
     (message "Continuing with partial configuration...")))
  
  ;; Enable auto-reload by default
  (literate-config-watch-enable)
  
  (message "Literate Config System v4.3.0 initialized with auto-reload"))
;;;###autoload
(defun literate-config-help ()
  "Display quick start guide."
  (interactive)
  (with-current-buffer (get-buffer-create "*Literate Config Help*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "════════════════════════════════════════════════════════════\n")
      (insert "  LITERATE CONFIG SYSTEM v4.3.0 — Quick Start Guide\n")
      (insert "════════════════════════════════════════════════════════════\n\n")
      
      (insert "COMMANDS\n")
      (insert "────────\n")
      (insert "M-x literate-config-create-package    Create new package\n")
      (insert "M-x literate-config-watch-toggle      Toggle auto-reload\n")
      (insert "M-x literate-config-watch-enable      Enable auto-reload\n")
      (insert "M-x literate-config-watch-disable     Disable auto-reload\n")
      (insert "M-x literate-config-help              Show this help\n\n")
      
      (insert "AUTO-RELOAD\n")
      (insert "───────────\n")
      (insert "The system automatically reloads when you save .org files\n")
      (insert "in your literate config directory. Changes are debounced\n")
      (insert "with a 1-second delay to avoid multiple reloads.\n\n")
      (insert "Status: ")
      (if literate-config--auto-reload-enabled
          (insert "ENABLED ✓\n\n")
        (insert "DISABLED ✗\n\n"))
      
      (insert "PACKAGE FILE STRUCTURE\n")
      (insert "──────────────────────\n\n")
      (insert "* Package-Name\n")
      (insert ":PROPERTIES:\n")
      (insert ":PACKAGE:  package-name\n")
      (insert ":STRAIGHT: (package-name :type git :host github :repo \"user/repo\")\n")
      (insert ":AFTER:    org                  ← Load after these packages\n")
      (insert ":DEPENDS:  dep1 dep2            ← Auto-install these packages\n")
      (insert ":VERSION:  v1.0.0\n")
      (insert ":END:\n\n")
      (insert "** Description\n")
      (insert ":PROPERTIES:\n")
      (insert ":tangle: no        ← Not loaded\n")
      (insert ":END:\n\n")
      (insert "** Dependencies\n")
      (insert ":PROPERTIES:\n")
      (insert ":tangle: no        ← Documentation only\n")
      (insert ":END:\n\n")
      (insert "** Initialization\n")
      (insert ":PROPERTIES:\n")
      (insert ":tangle: init      ← Goes to :init (runs BEFORE package loads)\n")
      (insert ":END:\n")
      (insert "#+begin_src emacs-lisp\n")
      (insert ";; Pre-load setup\n")
      (insert "#+end_src\n\n")
      (insert "** Configuration\n")
      (insert "No :tangle: property needed - this goes to :config (runs AFTER)\n")
      (insert "#+begin_src emacs-lisp\n")
      (insert "(setq package-var 'value)\n")
      (insert "#+end_src\n\n")
      (insert "MULTI-PACKAGE FILES\n")
      (insert "───────────────────\n")
      (insert "You can have multiple packages in one .org file!\n")
      (insert "Just create multiple top-level (* Package-Name) headlines.\n")
      (insert "Each will be processed independently.\n\n")
      (insert "Example: notebook-mode.org could contain:\n")
      (insert "  * NOTEBOOK-MODE\n")
      (insert "  * SVG-TAG-MODE\n\n")
      
      (insert "CONFIGURATION\n")
      (insert "─────────────\n")
      (insert "Directory: " literate-config-emacs-org-directory "\n")
      (insert "Version enforcement: " (if literate-config-enforce-versions "enabled" "disabled") "\n")
      (insert "Auto-reload: " (if literate-config--auto-reload-enabled "enabled" "disabled") "\n\n")
      
      (insert "════════════════════════════════════════════════════════════\n")
      (goto-char (point-min))
      (special-mode)
      (display-buffer (current-buffer)))))
;; ════════════════════════════════════════════════════════════════════
;; § PROVIDE
;; ════════════════════════════════════════════════════════════════════
(provide 'literate-config-system)
;;; literate-config-system.el ends here
