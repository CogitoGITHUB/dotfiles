;;──────────────────────────────────────────────────────────
;; Straight bootstrap (must be first)
;;──────────────────────────────────────────────────────────
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)
;;──────────────────────────────────────────────────────────
;; Org (required, explicit, upstream)
;;──────────────────────────────────────────────────────────
(straight-use-package
 '(org :type git
       :host git
       :repo "https://git.savannah.gnu.org/git/emacs/org-mode.git"))
(require 'org)
;;──────────────────────────────────────────────────────────
;; Leaf system
;;──────────────────────────────────────────────────────────
(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(require 'leaf)
(require 'leaf-keywords)
(leaf-keywords-init)

;;──────────────────────────────────────────────────────────
;; Primitive built-in configuration with leaf
;;──────────────────────────────────────────────────────────
(leaf cus-start
  :doc "builtin core configuration"
  :tag "builtin"
  :custom ((truncate-lines . t)
           (menu-bar-mode . nil)
           (tool-bar-mode . nil)
           (scroll-bar-mode . nil)
           (inhibit-startup-screen . t)
           (initial-scratch-message . nil)
           (ring-bell-function . 'ignore)
           (use-dialog-box . nil)
           (cursor-in-non-selected-windows . nil)
           (frame-title-format . "%b")
           (fringe-mode . 0)))
(setq-default mode-line-format nil)
(setq mode-line-format nil)

;;; shaping.el --- Managed Emacs configuration through org files
;; Copyright (C) 2025
;; Author: Internal implementation

;;; Commentary:
;; This version works exclusively with leaf package declarations.
;; Remote functionality has been removed.

(require 'cl-lib)
(require 'ob-core)

;;; Code:

(defvar shaping-packages '()
  "List of packages that should be installed.
This is a plist where keys are package symbols and values are
plists containing package configuration like :init, :config, :bind, etc.")

(defvar shaping--booting nil
  "Non-nil when running inside `shaping-boot'.
Used internally to control behavior during the boot process.")

(defvar shaping--boot-errors '()
  "List of compile/loading errors encountered during shaping boot.
Each error is a plist with :file, :line, and :message keys.")

(defcustom shaping-wrap-statements-in-condition t
  "Wrap code in condition-case statements.
When non-nil, all code blocks are wrapped in condition-case forms
to catch and report errors without stopping the entire boot process.
Set to nil for debugging to see raw errors."
  :type 'boolean
  :group 'shaping)

(defcustom shaping-leaf-keywords
  '("after" "demand" "ensure" "config" "init" "bind" "bind*" 
    "hook" "general" "custom" "defer" "requires" "straight")
  "List of `leaf' keywords that can be used as org tags.
The keywords are case sensitive. If a tag ends with an underscore,
it will be replaced with an asterisk in the generated code.

Example: A tag 'bind_' becomes ':bind*' in the leaf declaration."
  :type 'list
  :group 'shaping)

(defcustom shaping-output-directory 
  (expand-file-name "shaped-packages" user-emacs-directory)
  "Directory where the compiled Elisp files are stored.
This directory is automatically created if it doesn't exist.
Files in this directory are auto-generated and should not be edited manually."
  :type 'string
  :group 'shaping)

(defcustom shaping-org-directory 
  (expand-file-name "shaping-packages" user-emacs-directory)
  "Directory where the source Org files are stored.
This is where you should place your configuration org files.
Subdirectories are supported and will maintain their structure
in the output directory."
  :type 'string
  :group 'shaping)

(defcustom shaping-force-compile nil
  "Force compilation of Org files even if elisp file is newer.
When non-nil, always recompile org files regardless of timestamps.
Useful for debugging or when you've modified shaping.el itself."
  :type 'boolean
  :group 'shaping)

(defun shaping-indent (string n)
  "Indent STRING by N spaces.
Adds N spaces to the beginning of each line in STRING.

Example:
  (shaping-indent \"hello\\nworld\" 2)
  => \"  hello\\n  world\""
  (let ((indentation (make-string n ?\s)))
    (replace-regexp-in-string "^" indentation string)))

(defun shaping-plist-keys (plist)
  "Return the keys of PLIST as a list.
Extracts all keys (every other element starting from position 0)
from a property list.

Example:
  (shaping-plist-keys '(:a 1 :b 2 :c 3))
  => (:a :b :c)"
  (let ((keys '()))
    (while plist
      (push (car plist) keys)
      (setq plist (cddr plist)))
    (nreverse keys)))

(defun shaping-find-property (property)
  "Find PROPERTY in the current Org element or any ancestor element.
Walks up the org tree from the current position until it finds
an element with the specified PROPERTY, or returns nil if not found.

Used to inherit properties from parent headlines."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property property (org-element-context)))
            (org-up-element))
          (intern (org-element-property property (org-element-context))))
      (error nil))))

(defun shaping-find-tags ()
  "Find tags in the current Org element or any ancestor element.
Returns a list of tags from the nearest headline with tags,
searching upward from the current position."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property :tags 
                        (org-element-lineage (org-element-context) '(headline) t)))
            (org-up-element))
          (org-element-property :tags 
            (org-element-lineage (org-element-context) '(headline) t)))
      (error nil))))

(defun shaping-find-tag ()
  "Find a `leaf' tag in the current Org element or any ancestor element.
Looks for tags that match keywords in `shaping-leaf-keywords'.
Converts underscores to hyphens and trailing underscores to asterisks.

Example: 'bind_' tag becomes 'bind*'"
  (let* ((keywords shaping-leaf-keywords)
         (tag (car (seq-filter (lambda (tag) (member tag keywords)) 
                               (shaping-find-tags)))))
    (when tag
      (replace-regexp-in-string "_" "-"
                                (replace-regexp-in-string "_$" "*" tag)))))

(defun shaping-find-package ()
  "Find a `leaf' package name in the current Org element or ancestor.
Searches for :PACKAGE:, :LEAF_PACKAGE:, or :LEAF-PACKAGE: properties.
Returns the package name as a symbol."
  (or (shaping-find-property :PACKAGE)
      (shaping-find-property :LEAF_PACKAGE)
      (shaping-find-property :LEAF-PACKAGE)))

(defun shaping-find-after ()
  "Find a `leaf' :after property in current or ancestor element.
The :AFTER: property specifies which packages must be loaded first.
Returns a string representation suitable for leaf's :after keyword."
  (when-let* ((after (shaping-find-property :AFTER)))
    (prin1-to-string (read (symbol-name after)))))

(defun shaping-find-demand ()
  "Find a `leaf' :demand property in current or ancestor element.
The :DEMAND: property forces immediate loading of a package.
Returns a string representation (typically 't' or 'nil')."
  (when-let* ((demand (shaping-find-property :DEMAND)))
    (prin1-to-string (read (symbol-name demand)))))

(defun shaping-find-ensure ()
  "Find a `leaf' :ensure property in current or ancestor element.
The :ENSURE: property controls whether the package should be installed.
Returns a string representation (typically 't' or 'nil')."
  (when-let* ((ensure (shaping-find-property :ENSURE)))
    (prin1-to-string (read (symbol-name ensure)))))

(defun shaping-find-defer ()
  "Find a `leaf' :defer property in current or ancestor element.
The :DEFER: property delays package loading.
Returns a string representation (number of seconds or 't')."
  (when-let* ((defer (shaping-find-property :DEFER)))
    (prin1-to-string (read (symbol-name defer)))))

(defun shaping-find-requires ()
  "Find a `leaf' :requires property in current or ancestor element.
The :REQUIRES: property specifies features that must be present.
Returns a string representation."
  (when-let* ((requires (shaping-find-property :REQUIRES)))
    (prin1-to-string (read (symbol-name requires)))))

(defun shaping-find-straight ()
  "Find a `leaf' :straight property in current or ancestor element.
The :STRAIGHT: property provides straight.el specific configuration.
Returns a string representation."
  (when-let* ((straight (shaping-find-property :STRAIGHT)))
    (prin1-to-string (read (symbol-name straight)))))

(defun shaping-find-keyword ()
  "Find a `leaf' keyword property in current or ancestor element.
Looks for a :KEYWORD: property which explicitly specifies the leaf
keyword to use (e.g., ':init', ':config'). Strips the leading colon."
  (when-let* ((keyword (shaping-find-property :KEYWORD)))
    (replace-regexp-in-string "^:" "" (symbol-name keyword))))

(defun shaping-get-leaf-package ()
  "Return the package name and Leaf keyword for current context.
Returns a list of (PACKAGE-SYMBOL KEYWORD-STRING) or nil.
The keyword comes from either a :KEYWORD: property or a matching tag."
  (when-let* ((package (shaping-find-package))
              (keyword (or (shaping-find-keyword)
                          (shaping-find-tag))))
    (list package keyword)))

(defun shaping-file-properties (file)
  "Return all #+PROPERTY directives from an org FILE as an alist.
Parses lines like '#+PRIORITY: 5' or '#+LEXICAL_BINDING: t'
and returns them as ((priority . \"5\") (lexical_binding . \"t\"))."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let (properties)
      (goto-char (point-min))
      (while (re-search-forward 
              "^\\(?:;;[ \t]*\\)?#\\+\\([A-Za-z0-9_]+\\):[ \t]*\\(.*\\)$" 
              nil t)
        (let ((key (intern (downcase (match-string 1))))
              (value (match-string 2)))
          (push (cons key value) properties)))
      properties)))

(defun shaping-file-priority (file)
  "Return the priority of an org FILE.
Looks for #+PRIORITY: directive. If not found or invalid, returns 10.
Lower numbers load first, higher numbers load last.

Example:
  #+PRIORITY: 1  ; Loads early
  #+PRIORITY: 99 ; Loads late"
  (let ((priority (alist-get 'priority (shaping-file-properties file) "10")))
    (if (string-match-p "^[0-9]+$" priority)
        (string-to-number priority)
      10)))

(defun shaping-file-lexical-binding (file)
  "Return the lexical-binding setting of an org FILE.
Looks for #+LEXICAL_BINDING: directive. Returns t unless explicitly
set to 'nil'. This controls whether the compiled elisp uses lexical
or dynamic binding."
  (let ((lexical-binding 
         (alist-get 'lexical_binding (shaping-file-properties file) "t")))
    (if (string= lexical-binding "nil")
        nil
      t)))

(defun shaping-get-files (extension directory)
  "Return all files matching EXTENSION in DIRECTORY, sorted by priority.
EXTENSION should be a regex pattern (e.g., \"^[^#]*\\\\.org$\").
Files are sorted using `shaping-file-priority' so lower priorities load first."
  (when (file-exists-p directory)
    (let* ((files (directory-files-recursively directory extension)))
      (sort files (lambda (a b) 
                    (< (shaping-file-priority a)
                       (shaping-file-priority b)))))))

(defun shaping-safe-read (string file &optional line)
  "Read STRING as elisp and return the result.
If STRING is not a valid Elisp form, displays a warning and returns nil.
FILE is the file name for error reporting.
LINE is the optional line number for error reporting."
  (condition-case err
      (read string)
    (error
     (display-warning
      'shaping
      (if line
          (format "failed to read body of %s:%s" file line)
        (format "failed to read body of %s" file))
      :error)
     nil)))

(defun shaping-wrap-in-condition (file part)
  "Wrap PART in a `condition-case' form for safe evaluation.
FILE is the file name for error reporting.
PART is a plist with :body (the code) and :line (line number).

When `shaping-wrap-statements-in-condition' is t, wraps the code
in error handling that collects errors without stopping execution.
Otherwise returns the code as-is for easier debugging."
  (let* ((body (plist-get part :body))
         (line (plist-get part :line))
         (expression-string (string-trim-right body))
         (expression (shaping-safe-read (format "(progn\n%s)" expression-string) 
                                        file line)))
    (if shaping-wrap-statements-in-condition
        (pp-to-string
         `(condition-case err
              ,expression
            (error
             (add-to-list 'shaping--boot-errors
                          (list :file ,(format "%s" file)
                                :line ,line
                                :message (error-message-string err)))
             (unless shaping--booting
               (display-warning
                'shaping
                (format "Error loading %s:%s - %s"
                        ,(format "%s" file)
                        ,line
                        (error-message-string err))
                :error)))))
      expression-string)))

(defun shaping-merge-bodies (file xs)
  "Merge the bodies of a list of leaf statements into a single list.
FILE is the file name for error reporting.
XS is a list of plists, each containing :body and :line.

Used to combine multiple :bind, :hook, etc. declarations into
a single list for the leaf form."
  (let ((result '()))
    (dolist (x xs)
      (let* ((body (plist-get x :body))
             (line (plist-get x :line))
             (result-body (shaping-safe-read body file line)))
        (when result-body
          (setq result (append result result-body)))))
    (when result
      (prin1-to-string result))))

(defun shaping-build-leaf-string (package-name package file)
  "Build a complete `leaf' declaration for PACKAGE-NAME as a string.
PACKAGE is a plist containing all configuration for the package.
FILE is the org file name for error reporting.

Constructs a leaf form with all applicable keywords:
  :straight, :ensure, :require, :after, :defer, :demand,
  :bind*, :bind, :hook, :init, :custom, :config

Each section is only included if configuration exists for it."
  (concat
   (string-trim-right
    (concat (format "(leaf %s" package-name)
            ;; Leaf supports :straight
            (when-let* ((straight (plist-get (car (plist-get package :straight)) 
                                             :body)))
              (format "\n  :straight %s" straight))
            ;; Leaf uses :ensure
            (when-let* ((ensure (plist-get (car (plist-get package :ensure)) 
                                           :body)))
              (format "\n  :ensure %s" ensure))
            ;; Leaf supports :require (not :requires)
            (when-let* ((requires (plist-get (car (plist-get package :requires)) 
                                             :body)))
              (format "\n  :require %s" requires))
            ;; Leaf supports :after
            (when-let* ((after (plist-get (car (plist-get package :after)) 
                                          :body)))
              (format "\n  :after %s" after))
            ;; Leaf supports :defer
            (when-let* ((defer (plist-get (car (plist-get package :defer)) 
                                          :body)))
              (format "\n  :defer %s" defer))
            ;; Leaf supports :demand
            (when-let* ((demand (plist-get (car (plist-get package :demand)) 
                                           :body)))
              (format "\n  :demand %s" demand))
            ;; Leaf supports :bind*
            (when-let* ((bind* (shaping-merge-bodies file 
                                                     (plist-get package :bind*))))
              (format "\n  :bind*\n%s" (shaping-indent bind* 2)))
            ;; Leaf supports :bind
            (when-let* ((bind (shaping-merge-bodies file 
                                                    (plist-get package :bind))))
              (format "\n  :bind\n%s" (shaping-indent bind 2)))
            ;; Leaf supports :hook
            (when-let* ((hook (shaping-merge-bodies file 
                                                    (plist-get package :hook))))
              (format "\n  :hook\n%s" (shaping-indent hook 2)))
            ;; Leaf supports :init
            (when-let* ((init (plist-get package :init)))
              (format "\n  :init\n%s" 
                      (shaping-indent 
                       (string-join 
                        (mapcar (lambda (x) (shaping-wrap-in-condition file x)) 
                                init) 
                        "\n") 
                       2)))
            ;; Leaf supports :custom
            (when-let* ((custom (plist-get package :custom)))
              (let ((custom-forms (mapcar (lambda (part) 
                                           (string-trim (plist-get part :body)))
                                         custom)))
                (format "\n  :custom\n  %s" (string-join custom-forms "\n  "))))
            ;; Leaf supports :config
            (when-let* ((config (plist-get package :config)))
              (format "\n  :config\n%s" 
                      (shaping-indent 
                       (string-join 
                        (mapcar (lambda (x) (shaping-wrap-in-condition file x)) 
                                config) 
                        "\n") 
                       2)))))
   ")\n\n"))

(defun shaping-build-leaf (file package-name)
  "Build a `leaf' block for PACKAGE-NAME as a string.
FILE is the org file name for error reporting.
PACKAGE-NAME is the symbol naming the package.

Returns nil if the package is 'nil or has invalid syntax."
  (when-let* ((package (plist-get shaping-packages package-name)))
    (when (not (equal package-name (intern "nil")))
      (let ((package-string (shaping-build-leaf-string package-name package file)))
        (when (shaping-safe-read package-string file)
          package-string)))))

(defun shaping-build-leafs (file)
  "Build a string containing all `leaf' blocks for FILE.
Iterates through all packages in `shaping-packages' and generates
their leaf declarations, concatenating them into a single string."
  (let ((package-names (shaping-plist-keys shaping-packages))
        (result ""))
    (dolist (package-name package-names)
      (setq result (concat result (shaping-build-leaf file package-name))))
    result))

(defun shaping-put-package-parameter (package-name parameter value)
  "Store a PARAMETER with VALUE for PACKAGE-NAME in `shaping-packages'.
PACKAGE-NAME is a symbol identifying the package.
PARAMETER is a keyword (e.g., :init, :config).
VALUE is the value to store (typically a list of plists with :body and :line)."
  (setq shaping-packages
        (plist-put
         shaping-packages
         package-name
         (plist-put (plist-get shaping-packages package-name)
                    parameter
                    value))))

(defun shaping-add-package (package body element)
  "Add a code block BODY to PACKAGE configuration.
PACKAGE is a list of (PACKAGE-NAME KEYWORD-STRING).
BODY is the source code as a string.
ELEMENT is the org element for extracting metadata.

This function is called for each source block tagged with a package
name and keyword (like 'init' or 'config'). It accumulates all such
blocks for later assembly into a leaf declaration."
  (let* ((begin (org-element-property :begin element))
         (line (line-number-at-pos begin))
         (package-name (car package))
         (package-parameter (intern (concat ":" (car (cdr package)))))
         (previous-body (plist-get (plist-get shaping-packages package-name) 
                                   package-parameter))
         (value (append previous-body `((:body ,body :line ,line)))))
    (shaping-put-package-parameter package-name package-parameter value)
    nil))

(defun shaping-concatenate-source-blocks (file)
  "Process FILE and extract all configuration into strings and package data.
This function:
  1. Parses org properties from headlines to extract package metadata
  2. Processes each source block:
     - If it belongs to a package (has :PACKAGE: and keyword tag),
       adds it to `shaping-packages'
     - Otherwise, wraps it in error handling and adds to results
  3. Returns a string of standalone code (non-package blocks)

The package-specific blocks are not returned - they're accumulated
in `shaping-packages' for later assembly by `shaping-build-leafs'."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((results '()))
      ;; First pass: extract properties from headlines
      (org-map-entries
       (lambda ()
         (let ((line (line-number-at-pos 
                     (org-element-property :begin (org-element-context)))))
           ;; Store package name line number
           (when-let* ((package-name (shaping-find-package))
                       (package (org-element-property :PACKAGE 
                                                      (org-element-context))))
             (shaping-put-package-parameter package-name :package line))
           ;; Extract all leaf properties
           (when-let* ((package-name (shaping-find-package))
                       (after (shaping-find-after)))
             (shaping-put-package-parameter package-name :after 
                                           `((:body ,after :line ,line))))
           (when-let* ((package-name (shaping-find-package))
                       (demand (shaping-find-demand)))
             (shaping-put-package-parameter package-name :demand 
                                           `((:body ,demand :line ,line))))
           (when-let* ((package-name (shaping-find-package))
                       (ensure (shaping-find-ensure)))
             (shaping-put-package-parameter package-name :ensure 
                                           `((:body ,ensure :line ,line))))
           (when-let* ((package-name (shaping-find-package))
                       (defer (shaping-find-defer)))
             (shaping-put-package-parameter package-name :defer 
                                           `((:body ,defer :line ,line))))
           (when-let* ((package-name (shaping-find-package))
                       (requires (shaping-find-requires)))
             (shaping-put-package-parameter package-name :requires 
                                           `((:body ,requires :line ,line))))
           (when-let* ((package-name (shaping-find-package))
                       (straight (shaping-find-straight)))
             (shaping-put-package-parameter package-name :straight 
                                           `((:body ,straight :line ,line)))))))
      ;; Second pass: process source blocks
      (org-babel-map-src-blocks nil
        (let ((body (org-element-property :value (org-element-context)))
              (line (line-number-at-pos 
                    (org-element-property :begin (org-element-context))))
              (language (org-element-property :language (org-element-context))))
          (when (string= language "emacs-lisp")
            (if-let* ((package (shaping-get-leaf-package)))
                ;; This block belongs to a package - add to shaping-packages
                (shaping-add-package package body (org-element-context))
              ;; Standalone block - add to results
              (when (stringp body)
                (push (shaping-wrap-in-condition file `(:body ,body :line ,line))
                      results))))))
      ;; Return concatenated standalone blocks
      (mapconcat 'identity (reverse results) "\n"))))

(defun shaping-output-file-name (file)
  "Return the output elisp file path for org FILE.
Maintains directory structure relative to `shaping-org-directory'.
Output goes to `shaping-output-directory' with .el extension.

Example:
  Input:  ~/.emacs.d/shaping-packages/ui/theme.org
  Output: ~/.emacs.d/shaped-packages/ui/theme.el"
  (if (string-prefix-p
       (expand-file-name shaping-org-directory)
       (expand-file-name file))
      (expand-file-name
       (concat (file-name-as-directory shaping-output-directory)
               (file-name-sans-extension 
                (substring file (length (expand-file-name shaping-org-directory))))
               ".el"))
    (error "File is not in shaping-org-directory")))

(defun shaping-compile-file (file)
  "Compile org FILE to elisp.
FILE is an org file path.
Output is stored in `shaping-output-directory'.

Process:
  1. Check if compilation is needed (file newer or force compile)
  2. Extract standalone code and package configurations
  3. Generate leaf declarations for all packages
  4. Write combined output with file properties as comments
  5. Set file timestamp to current time

Returns the output file path or nil if no compilation occurred."
  (unless (file-exists-p file)
    (error "File to tangle does not exist: %s" file))
  (unless (file-exists-p shaping-output-directory)
    (make-directory shaping-output-directory t))
  (let ((output-file (shaping-output-file-name file)))
    (make-directory (file-name-directory output-file) t)
    (when (or shaping-force-compile
              (file-newer-than-file-p file output-file))
      (message "Shaping: Compiling %s" file)
      (let* ((shaping-packages nil)  ; Reset for this file
             (source (shaping-concatenate-source-blocks file))
             (output (concat source "\n" (shaping-build-leafs file))))
        (with-temp-file output-file
          ;; Add lexical binding marker if needed
          (when (shaping-file-lexical-binding file)
            (insert ";;; -*- lexical-binding: t -*-\n"))
          ;; Add file properties as comments
          (dolist (property (shaping-file-properties file))
            (insert (format ";; #+%s: %s\n\n"
                            (upcase (symbol-name (car property)))
                            (cdr property))))
          (insert output)))
      ;; Touch file to update timestamp
      (when (file-exists-p output-file)
        (set-file-times output-file))
      output-file)))

(defun shaping-compile-directory ()
  "Compile all org files in `shaping-org-directory' to elisp.
Processes files in priority order (lowest priority numbers first).
Returns a list of compiled output file paths."
  (let* ((files (shaping-get-files "^[^#]*\\.org$" shaping-org-directory))
         (compiled '()))
    (dolist (file files)
      (when-let* ((output (shaping-compile-file file)))
        (push output compiled)))
    compiled))

(defun shaping-load-file (file)
  "Load elisp FILE with quiet messages.
Reports success or failure via messages."
  (let ((inhibit-message t))
    (if (load (expand-file-name file) nil t)
        (message "Shaping: Loaded %s" file)
      (message "Shaping: Failed to load %s" file))))

(defun shaping-load-directory ()
  "Load all compiled elisp files from `shaping-output-directory'.
Loads files in priority order with error handling.
Temporarily increases garbage collection threshold for performance.
Errors are collected in `shaping--boot-errors' and displayed."
  (let* ((initial-gc-cons-threshold gc-cons-threshold)
         (files (shaping-get-files "^[^#]*\\.el$" shaping-output-directory)))
    ;; Increase GC threshold during loading for performance
    (setq gc-cons-threshold (* 1024 1024 100))
    (dolist (file files)
      (condition-case err
          (shaping-load-file file)
        (error
         (add-to-list 'shaping--boot-errors
                      (list :file (format "%s" file)
                            :line 1
                            :message (error-message-string err)))
         (unless shaping--booting
           (display-warning
            'shaping
            (format "Error loading %s:%s - %s"
                    (format "%s" file)
                    1
                    (error-message-string err))
            :error)))))
    ;; Restore GC threshold
    (setq gc-cons-threshold initial-gc-cons-threshold)
    nil))

(defun shaping-reload ()
  "Compile and load all org files.
Use this after making changes to multiple files or when you want
to ensure everything is up to date."
  (interactive)
  (dolist (compiled-file (shaping-compile-directory))
    (shaping-load-file compiled-file)))

(defun shaping-reload-current-buffer ()
  "Compile and load the current org file.
Quick way to test changes to a single configuration file.
Forces compilation even if the file hasn't changed."
  (interactive)
  (let ((shaping-force-compile t))
    (when-let* ((compiled-file (shaping-compile-file 
                                (buffer-file-name (current-buffer)))))
      (shaping-load-file compiled-file))))

(defun shaping-preview ()
  "Display the compiled elisp for the current buffer in a preview window.
Shows what will be generated without actually loading it.
Useful for debugging and understanding how your org file translates to elisp."
  (interactive)
  (let* ((buffer (get-buffer-create "*shaping preview*"))
         (_ (display-buffer buffer))
         (shaping-wrap-statements-in-condition nil)
         (file (buffer-file-name (current-buffer)))
         (shaping-packages nil)
         (source (shaping-concatenate-source-blocks file))
         (output (concat source "\n" (shaping-build-leafs file))))
    (with-current-buffer buffer
      (emacs-lisp-mode)
      (read-only-mode 1)
      (save-excursion
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert output)
          (goto-char (point-min)))))))

(define-minor-mode shaping-preview-mode
  "Minor mode to auto-preview compiled elisp on save.
When enabled, the preview buffer updates automatically whenever
you save the org file."
  :lighter " shaping-preview"
  (if shaping-preview-mode
      (add-hook 'after-save-hook 'shaping-preview nil t)
    (remove-hook 'after-save-hook 'shaping-preview t)))

(defun shaping-boot ()
  "Compile and load all org files - the main entry point.
This is called automatically when shaping.el loads, and can be
called manually to reload everything.

Process:
  1. Set `shaping--booting' flag
  2. Clear previous boot errors
  3. Compile all org files in priority order
  4. Load all compiled elisp files in priority order"
  (interactive)
  (let ((shaping--booting t))
    (setq shaping--boot-errors '())
    (shaping-compile-directory)
    (shaping-load-directory)))

;; Initialize shaping directories and perform initial boot
(setq shaping-org-directory    (expand-file-name "shaping-packages" 
                                                 user-emacs-directory)
      shaping-output-directory (expand-file-name "shaped-packages" 
                                                 user-emacs-directory))

;; Boot the system on load
(shaping-boot)

;; Enable preview mode for all org files
(add-hook 'org-mode-hook #'shaping-preview-mode)

(defun shaping/auto-compile-and-reload ()
  "Auto-compile and reload when an org file in shaping-org-directory is saved.
This provides immediate feedback when editing configuration files."
  (when (and buffer-file-name
             (file-in-directory-p buffer-file-name shaping-org-directory)
             (string-suffix-p ".org" buffer-file-name))
    (message "Shaping: Compiling and reloading %s…" 
             (file-name-nondirectory buffer-file-name))
    (condition-case err
        (let ((shaping-force-compile t))
          (when-let ((compiled-file (shaping-compile-file buffer-file-name)))
            (shaping-load-file compiled-file)
            (message "Shaping: Reload complete ✓")))
      (error
       (display-warning
        'shaping 
        (format "Failed to compile/reload: %s" (error-message-string err)) 
        :error)))))

;; Enable auto-reload
(add-hook 'after-save-hook #'shaping/auto-compile-and-reload)

(provide 'shaping)
;;; shaping.el ends here

;;; guix-shaping.el --- Managed Guix package definitions through org files
;; Copyright (C) 2025
;; Author: Internal implementation

;;; Commentary:
;; This system generates Guix package definitions from org-mode files.
;; Each package is defined using org properties and source blocks.

(require 'cl-lib)
(require 'ob-core)

;;; Code:

(defvar guix-shaping-packages '()
  "List of Guix packages being defined.
This is a plist where keys are package symbols and values are
plists containing package metadata like :version, :source, :synopsis, etc.")

(defvar guix-shaping--booting nil
  "Non-nil when running inside `guix-shaping-boot'.
Used internally to control behavior during the boot process.")

(defvar guix-shaping--boot-errors '()
  "List of compile/loading errors encountered during guix-shaping boot.
Each error is a plist with :file, :line, and :message keys.")

(defcustom guix-shaping-wrap-statements-in-condition t
  "Wrap code in condition-case statements.
When non-nil, code is wrapped to catch and report errors.
Set to nil for debugging to see raw errors."
  :type 'boolean
  :group 'guix-shaping)

(defcustom guix-shaping-package-fields
  '("name" "version" "source" "build-system" "arguments" "inputs" 
    "native-inputs" "propagated-inputs" "outputs" "home-page" 
    "synopsis" "description" "license" "properties" "supported-systems")
  "List of Guix package fields that can be used as org tags.
These correspond to standard Guix package definition fields."
  :type 'list
  :group 'guix-shaping)

(defcustom guix-shaping-output-directory 
  (expand-file-name "guix-shaped" user-emacs-directory)
  "Directory where the compiled Guix Scheme files are stored.
This directory is automatically created if it doesn't exist.
Files in this directory are auto-generated and should not be edited manually."
  :type 'string
  :group 'guix-shaping)

(defcustom guix-shaping-org-directory 
  (expand-file-name "guix-packages" user-emacs-directory)
  "Directory where the source Org files are stored.
This is where you should place your package definition org files."
  :type 'string
  :group 'guix-shaping)

(defcustom guix-shaping-force-compile nil
  "Force compilation of Org files even if Scheme file is newer.
When non-nil, always recompile org files regardless of timestamps."
  :type 'boolean
  :group 'guix-shaping)

(defun guix-shaping-indent (string n)
  "Indent STRING by N spaces.
Adds N spaces to the beginning of each line in STRING."
  (let ((indentation (make-string n ?\s)))
    (replace-regexp-in-string "^" indentation string)))

(defun guix-shaping-plist-keys (plist)
  "Return the keys of PLIST as a list.
Extracts all keys from a property list."
  (let ((keys '()))
    (while plist
      (push (car plist) keys)
      (setq plist (cddr plist)))
    (nreverse keys)))

(defun guix-shaping-symbol-to-scheme (symbol)
  "Convert elisp SYMBOL to Guix-style naming.
Example: 'emacs-my-package becomes 'emacs-my-package"
  (replace-regexp-in-string "_" "-" (symbol-name symbol)))

(defun guix-shaping-find-property (property)
  "Find PROPERTY in the current Org element or any ancestor element.
Walks up the org tree from the current position until it finds
an element with the specified PROPERTY, or returns nil if not found."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property property (org-element-context)))
            (org-up-element))
          (org-element-property property (org-element-context)))
      (error nil))))

(defun guix-shaping-find-tags ()
  "Find tags in the current Org element or any ancestor element.
Returns a list of tags from the nearest headline with tags."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property :tags 
                        (org-element-lineage (org-element-context) '(headline) t)))
            (org-up-element))
          (org-element-property :tags 
            (org-element-lineage (org-element-context) '(headline) t)))
      (error nil))))

(defun guix-shaping-find-tag ()
  "Find a Guix package field tag in current or ancestor element.
Looks for tags that match fields in `guix-shaping-package-fields'."
  (let* ((fields guix-shaping-package-fields)
         (tag (car (seq-filter (lambda (tag) (member tag fields)) 
                               (guix-shaping-find-tags)))))
    (when tag
      (replace-regexp-in-string "_" "-" tag))))

(defun guix-shaping-find-package ()
  "Find a Guix package name in current or ancestor element.
Searches for :PACKAGE: or :NAME: properties.
Returns the package name as a string."
  (or (guix-shaping-find-property :PACKAGE)
      (guix-shaping-find-property :NAME)))

(defun guix-shaping-find-version ()
  "Find package :VERSION: property."
  (guix-shaping-find-property :VERSION))

(defun guix-shaping-find-module ()
  "Find module definition :MODULE: property.
Example: '(my-packages emacs)'"
  (guix-shaping-find-property :MODULE))

(defun guix-shaping-find-use-modules ()
  "Find :USE_MODULES: property for module imports."
  (guix-shaping-find-property :USE_MODULES))

(defun guix-shaping-find-license ()
  "Find :LICENSE: property."
  (guix-shaping-find-property :LICENSE))

(defun guix-shaping-find-home-page ()
  "Find :HOME_PAGE: property."
  (guix-shaping-find-property :HOME_PAGE))

(defun guix-shaping-find-synopsis ()
  "Find :SYNOPSIS: property."
  (guix-shaping-find-property :SYNOPSIS))

(defun guix-shaping-find-build-system ()
  "Find :BUILD_SYSTEM: property."
  (guix-shaping-find-property :BUILD_SYSTEM))

(defun guix-shaping-find-field ()
  "Find a Guix package field property.
Looks for a :FIELD: property which explicitly specifies the field."
  (guix-shaping-find-property :FIELD))

(defun guix-shaping-get-package-field ()
  "Return the package name and field for current context.
Returns a list of (PACKAGE-NAME FIELD-STRING) or nil."
  (when-let* ((package (guix-shaping-find-package))
              (field (or (guix-shaping-find-field)
                        (guix-shaping-find-tag))))
    (list package field)))

(defun guix-shaping-file-properties (file)
  "Return all #+PROPERTY directives from an org FILE as an alist."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let (properties)
      (goto-char (point-min))
      (while (re-search-forward 
              "^\\(?:;;[ \t]*\\)?#\\+\\([A-Za-z0-9_]+\\):[ \t]*\\(.*\\)$" 
              nil t)
        (let ((key (intern (downcase (match-string 1))))
              (value (match-string 2)))
          (push (cons key value) properties)))
      properties)))

(defun guix-shaping-file-priority (file)
  "Return the priority of an org FILE.
Lower numbers compile first. Default is 10."
  (let ((priority (alist-get 'priority (guix-shaping-file-properties file) "10")))
    (if (string-match-p "^[0-9]+$" priority)
        (string-to-number priority)
      10)))

(defun guix-shaping-file-module (file)
  "Return the module name for FILE.
Looks for #+MODULE: directive, e.g., '(my-packages emacs)'."
  (alist-get 'module (guix-shaping-file-properties file)))

(defun guix-shaping-file-use-modules (file)
  "Return the use-modules list for FILE.
Looks for #+USE_MODULES: directive."
  (alist-get 'use_modules (guix-shaping-file-properties file)))

(defun guix-shaping-get-files (extension directory)
  "Return all files matching EXTENSION in DIRECTORY, sorted by priority."
  (when (file-exists-p directory)
    (let* ((files (directory-files-recursively directory extension)))
      (sort files (lambda (a b) 
                    (< (guix-shaping-file-priority a)
                       (guix-shaping-file-priority b)))))))

(defun guix-shaping-safe-read (string file &optional line)
  "Read STRING as elisp/scheme and return the result.
If STRING is not valid, displays a warning and returns nil."
  (condition-case err
      (read string)
    (error
     (display-warning
      'guix-shaping
      (if line
          (format "failed to read body of %s:%s" file line)
        (format "failed to read body of %s" file))
      :error)
     nil)))

(defun guix-shaping-wrap-field (file part)
  "Wrap PART for safe inclusion in package definition.
FILE is the file name for error reporting.
PART is a plist with :body and :line."
  (let* ((body (plist-get part :body))
         (line (plist-get part :line)))
    (string-trim-right body)))

(defun guix-shaping-put-package-parameter (package-name parameter value)
  "Store a PARAMETER with VALUE for PACKAGE-NAME.
PACKAGE-NAME is a string identifying the package.
PARAMETER is a keyword (e.g., :source, :description).
VALUE is the value to store."
  (setq guix-shaping-packages
        (plist-put
         guix-shaping-packages
         (intern package-name)
         (plist-put (plist-get guix-shaping-packages (intern package-name))
                    parameter
                    value))))

(defun guix-shaping-add-package-field (package body element)
  "Add a field BODY to PACKAGE configuration.
PACKAGE is a list of (PACKAGE-NAME FIELD-STRING).
BODY is the source code as a string.
ELEMENT is the org element for extracting metadata."
  (let* ((begin (org-element-property :begin element))
         (line (line-number-at-pos begin))
         (package-name (car package))
         (package-field (intern (concat ":" (car (cdr package)))))
         (previous-body (plist-get (plist-get guix-shaping-packages 
                                              (intern package-name)) 
                                   package-field))
         (value (append previous-body `((:body ,body :line ,line)))))
    (guix-shaping-put-package-parameter package-name package-field value)
    nil))

(defun guix-shaping-build-package-string (package-name package file)
  "Build a complete Guix package definition for PACKAGE-NAME.
PACKAGE is a plist containing all fields for the package.
FILE is the org file name for error reporting."
  (let* ((name (or (plist-get (car (plist-get package :name)) :body)
                  package-name))
         (version (plist-get (car (plist-get package :version)) :body))
         (source (plist-get (car (plist-get package :source)) :body))
         (build-system (plist-get (car (plist-get package :build-system)) :body))
         (arguments (plist-get (car (plist-get package :arguments)) :body))
         (inputs (plist-get (car (plist-get package :inputs)) :body))
         (native-inputs (plist-get (car (plist-get package :native-inputs)) :body))
         (propagated-inputs (plist-get (car (plist-get package :propagated-inputs)) :body))
         (home-page (plist-get (car (plist-get package :home-page)) :body))
         (synopsis (plist-get (car (plist-get package :synopsis)) :body))
         (description (plist-get (car (plist-get package :description)) :body))
         (license (plist-get (car (plist-get package :license)) :body))
         (properties (plist-get (car (plist-get package :properties)) :body))
         (supported-systems (plist-get (car (plist-get package :supported-systems)) :body)))
    (concat
     (format "(define-public %s\n" package-name)
     "  (package\n"
     (when name
       (format "    (name %s)\n" name))
     (when version
       (format "    (version %s)\n" version))
     (when source
       (format "    (source\n%s)\n" (guix-shaping-indent source 5)))
     (when build-system
       (format "    (build-system %s)\n" build-system))
     (when arguments
       (format "    (arguments\n%s)\n" (guix-shaping-indent arguments 5)))
     (when inputs
       (format "    (inputs\n%s)\n" (guix-shaping-indent inputs 5)))
     (when native-inputs
       (format "    (native-inputs\n%s)\n" (guix-shaping-indent native-inputs 5)))
     (when propagated-inputs
       (format "    (propagated-inputs\n%s)\n" (guix-shaping-indent propagated-inputs 5)))
     (when home-page
       (format "    (home-page %s)\n" home-page))
     (when synopsis
       (format "    (synopsis %s)\n" synopsis))
     (when description
       (format "    (description\n%s)\n" (guix-shaping-indent description 5)))
     (when license
       (format "    (license %s)\n" license))
     (when properties
       (format "    (properties\n%s)\n" (guix-shaping-indent properties 5)))
     (when supported-systems
       (format "    (supported-systems %s)\n" supported-systems))
     "  ))\n\n")))

(defun guix-shaping-build-package (file package-name)
  "Build a Guix package definition for PACKAGE-NAME.
FILE is the org file name.
PACKAGE-NAME is the symbol naming the package."
  (when-let* ((package (plist-get guix-shaping-packages package-name)))
    (guix-shaping-build-package-string (symbol-name package-name) package file)))

(defun guix-shaping-build-packages (file)
  "Build all package definitions from FILE.
Returns a string containing all package definitions."
  (let ((package-names (guix-shaping-plist-keys guix-shaping-packages))
        (result ""))
    (dolist (package-name package-names)
      (setq result (concat result (guix-shaping-build-package file package-name))))
    result))

(defun guix-shaping-concatenate-source-blocks (file)
  "Process FILE and extract all package definitions.
Parses org properties and source blocks to build package definitions.
Returns a string of standalone code (non-package blocks)."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((results '()))
      ;; First pass: extract properties from headlines
      (org-map-entries
       (lambda ()
         (let ((line (line-number-at-pos 
                     (org-element-property :begin (org-element-context)))))
           ;; Store package metadata from properties
           (when-let* ((package-name (guix-shaping-find-package)))
             (guix-shaping-put-package-parameter package-name :package line)
             
             (when-let* ((version (guix-shaping-find-version)))
               (guix-shaping-put-package-parameter 
                package-name :version `((:body ,version :line ,line))))
             
             (when-let* ((license (guix-shaping-find-license)))
               (guix-shaping-put-package-parameter 
                package-name :license `((:body ,license :line ,line))))
             
             (when-let* ((home-page (guix-shaping-find-home-page)))
               (guix-shaping-put-package-parameter 
                package-name :home-page `((:body ,home-page :line ,line))))
             
             (when-let* ((synopsis (guix-shaping-find-synopsis)))
               (guix-shaping-put-package-parameter 
                package-name :synopsis `((:body ,synopsis :line ,line))))
             
             (when-let* ((build-system (guix-shaping-find-build-system)))
               (guix-shaping-put-package-parameter 
                package-name :build-system `((:body ,build-system :line ,line))))))))
      
      ;; Second pass: process source blocks
      (org-babel-map-src-blocks nil
        (let ((body (org-element-property :value (org-element-context)))
              (line (line-number-at-pos 
                    (org-element-property :begin (org-element-context))))
              (language (org-element-property :language (org-element-context))))
          (when (or (string= language "scheme") (string= language "guile"))
            (if-let* ((package (guix-shaping-get-package-field)))
                ;; This block belongs to a package
                (guix-shaping-add-package-field package body (org-element-context))
              ;; Standalone block
              (when (stringp body)
                (push body results))))))
      ;; Return concatenated standalone blocks
      (mapconcat 'identity (reverse results) "\n"))))

(defun guix-shaping-output-file-name (file)
  "Return the output Scheme file path for org FILE.
Maintains directory structure and uses .scm extension."
  (if (string-prefix-p
       (expand-file-name guix-shaping-org-directory)
       (expand-file-name file))
      (expand-file-name
       (concat (file-name-as-directory guix-shaping-output-directory)
               (file-name-sans-extension 
                (substring file (length (expand-file-name guix-shaping-org-directory))))
               ".scm"))
    (error "File is not in guix-shaping-org-directory")))

(defun guix-shaping-build-module-header (file)
  "Build the module header for FILE.
Includes define-module and use-module declarations."
  (let* ((module (guix-shaping-file-module file))
         (use-modules (guix-shaping-file-use-modules file)))
    (concat
     (when module
       (format "(define-module %s\n" module))
     (when use-modules
       (concat "  " use-modules "\n"))
     (when module
       ")\n\n"))))

(defun guix-shaping-compile-file (file)
  "Compile org FILE to Guix Scheme.
FILE is an org file path.
Output is stored in `guix-shaping-output-directory'.
Returns the output file path or nil if no compilation occurred."
  (unless (file-exists-p file)
    (error "File to compile does not exist: %s" file))
  (unless (file-exists-p guix-shaping-output-directory)
    (make-directory guix-shaping-output-directory t))
  (let ((output-file (guix-shaping-output-file-name file)))
    (make-directory (file-name-directory output-file) t)
    (when (or guix-shaping-force-compile
              (file-newer-than-file-p file output-file))
      (message "Guix-Shaping: Compiling %s" file)
      (let* ((guix-shaping-packages nil)  ; Reset for this file
             (source (guix-shaping-concatenate-source-blocks file))
             (module-header (guix-shaping-build-module-header file))
             (packages (guix-shaping-build-packages file))
             (output (concat module-header source "\n" packages)))
        (with-temp-file output-file
          ;; Add file header comments
          (insert ";;; Generated by guix-shaping from " 
                  (file-name-nondirectory file) "\n")
          (insert ";;; Do not edit manually\n\n")
          (dolist (property (guix-shaping-file-properties file))
            (insert (format ";;; #+%s: %s\n"
                            (upcase (symbol-name (car property)))
                            (cdr property))))
          (insert "\n" output)))
      ;; Touch file to update timestamp
      (when (file-exists-p output-file)
        (set-file-times output-file))
      output-file)))

(defun guix-shaping-compile-directory ()
  "Compile all org files in `guix-shaping-org-directory' to Scheme.
Processes files in priority order.
Returns a list of compiled output file paths."
  (let* ((files (guix-shaping-get-files "^[^#]*\\.org$" 
                                        guix-shaping-org-directory))
         (compiled '()))
    (dolist (file files)
      (when-let* ((output (guix-shaping-compile-file file)))
        (push output compiled)))
    compiled))

(defun guix-shaping-compile ()
  "Compile all org files to Guix Scheme.
Use this after making changes to package definitions."
  (interactive)
  (let ((compiled (guix-shaping-compile-directory)))
    (message "Guix-Shaping: Compiled %d file(s)" (length compiled))))

(defun guix-shaping-compile-current-buffer ()
  "Compile the current org file.
Quick way to test changes to a single package definition file.
Forces compilation even if the file hasn't changed."
  (interactive)
  (let ((guix-shaping-force-compile t))
    (when-let* ((compiled-file (guix-shaping-compile-file 
                                (buffer-file-name (current-buffer)))))
      (message "Guix-Shaping: Compiled to %s" compiled-file))))

(defun guix-shaping-preview ()
  "Display the compiled Scheme for the current buffer.
Shows what will be generated without actually writing to file.
Useful for debugging package definitions."
  (interactive)
  (let* ((buffer (get-buffer-create "*guix-shaping preview*"))
         (_ (display-buffer buffer))
         (file (buffer-file-name (current-buffer)))
         (guix-shaping-packages nil)
         (source (guix-shaping-concatenate-source-blocks file))
         (module-header (guix-shaping-build-module-header file))
         (packages (guix-shaping-build-packages file))
         (output (concat module-header source "\n" packages)))
    (with-current-buffer buffer
      (scheme-mode)
      (read-only-mode 1)
      (save-excursion
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert output)
          (goto-char (point-min)))))))

(define-minor-mode guix-shaping-preview-mode
  "Minor mode to auto-preview compiled Scheme on save.
When enabled, the preview buffer updates automatically."
  :lighter " guix-preview"
  (if guix-shaping-preview-mode
      (add-hook 'after-save-hook 'guix-shaping-preview nil t)
    (remove-hook 'after-save-hook 'guix-shaping-preview t)))

(defun guix-shaping-boot ()
  "Compile all org files - the main entry point.
This can be called manually to recompile everything."
  (interactive)
  (let ((guix-shaping--booting t))
    (setq guix-shaping--boot-errors '())
    (guix-shaping-compile-directory)))

;; Initialize guix-shaping directories
(setq guix-shaping-org-directory    
      (expand-file-name "guix-packages" user-emacs-directory)
      guix-shaping-output-directory 
      (expand-file-name "guix-shaped" user-emacs-directory))

;; Enable preview mode for scheme/guile org blocks
(add-hook 'org-mode-hook 
          (lambda ()
            (when (and buffer-file-name
                       (file-in-directory-p buffer-file-name 
                                           guix-shaping-org-directory))
              (guix-shaping-preview-mode 1))))

(defun guix-shaping/auto-compile ()
  "Auto-compile when an org file in guix-shaping-org-directory is saved."
  (when (and buffer-file-name
             (file-in-directory-p buffer-file-name guix-shaping-org-directory)
             (string-suffix-p ".org" buffer-file-name))
    (message "Guix-Shaping: Compiling %s…" 
             (file-name-nondirectory buffer-file-name))
    (condition-case err
        (let ((guix-shaping-force-compile t))
          (when-let ((compiled-file (guix-shaping-compile-file buffer-file-name)))
            (message "Guix-Shaping: Compilation complete ✓")))
      (error
       (display-warning
        'guix-shaping 
        (format "Failed to compile: %s" (error-message-string err)) 
        :error)))))

;; Enable auto-compile
(add-hook 'after-save-hook #'guix-shaping/auto-compile)

(provide 'guix-shaping)
;;; guix-shaping.el ends here

(defun live-shaping/auto-tangle-and-reload ()
  "Auto-tangle and reload when this Org file tangles to init.el."
  (when (and buffer-file-name
             (save-excursion
               (goto-char (point-min))
               (re-search-forward ":tangle[ \t]+~/.config/emacs/init.el" nil t)))
    (message "Live-Shaping: Tangling…")
    (condition-case err
        (let ((target "~/.config/emacs/init.el")
              (temp   "~/.config/emacs/init.el.tmp"))
          (when (org-babel-tangle)
            (when (file-exists-p temp) (delete-file temp))
            (rename-file target temp t)
            (rename-file temp target t)
            (load-file target)
            (message "Live-Shaping: Reload complete ✓")))
      (error
       (display-warning
        'live-shaping (format "%s" (error-message-string err)) :error)))))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)

(leaf center-lock
  :config
  (defvar shapeshift/center-lock-enabled t
    "Whether the cursor should remain vertically centered.")

  (defun shapeshift/recenter-maybe ()
    (when (and shapeshift/center-lock-enabled
               (not (eq this-command 'scroll-up-command))
               (not (eq this-command 'scroll-down-command))
               (not (minibufferp)))
      (recenter)))

  (define-minor-mode center-lock-mode
    "Keep the cursor vertically centered at all times."
    :global t
    (if center-lock-mode
        (add-hook 'post-command-hook #'shapeshift/recenter-maybe)
      (remove-hook 'post-command-hook #'shapeshift/recenter-maybe)))

  (center-lock-mode 1))

(leaf font-config
  :config
  (defun shapeshift/apply-fonts ()
    (when (display-graphic-p)
      ;; ---------------------------------
      ;; PURE CALLIGRAPHY – THE ONE FONT
      ;; ---------------------------------
      (condition-case nil
          (progn
            ;; Set default font
            (set-face-attribute 'default nil
                                :family "Tangerine"
                                :height 110)
            (set-face-attribute 'variable-pitch nil
                                :family "Tangerine"
                                :height 110)
            (set-face-attribute 'fixed-pitch nil
                                :family "Tangerine"
                                :height 110)
            (message "Tangerine font applied successfully"))
        (error (message "Failed to apply Tangerine font - is it installed?")))
      
      ;; ---------------------------------
      ;; LIVING UNICODE FALLBACKS
      ;; ---------------------------------
      (condition-case nil
          (progn
            (set-fontset-font t 'unicode "Noto Sans Symbols" nil 'prepend)
            (set-fontset-font t 'unicode "Noto Sans" nil 'append)
            (set-fontset-font t 'unicode "Noto Sans Mono" nil 'append)
            (set-fontset-font t 'unicode "Noto Color Emoji" nil 'append))
        (error (message "Some Noto fonts may not be available")))))
  
  ;; Apply on startup
  (add-hook 'after-init-hook #'shapeshift/apply-fonts)
  
  ;; Apply when new frames are created
  (add-hook 'after-make-frame-functions
            (lambda (_frame) 
              (with-selected-frame _frame
                (shapeshift/apply-fonts))))
  
  ;; Apply immediately if already in graphical mode
  (when (display-graphic-p)
    (shapeshift/apply-fonts)))

(leaf pulsar
  :straight (pulsar
             :type git
             :host github
             :repo "protesilaos/pulsar"
             :fetch t)
  :bind
  ("C-x l" . pulsar-pulse-line)
  ("C-x L" . pulsar-highlight-permanently-dwim)
  :config
  (setq pulsar-delay 0.055
        pulsar-iterations 5
        pulsar-face 'pulsar-red
        pulsar-region-face 'pulsar-red
        pulsar-highlight-face 'pulsar-red)

  (pulsar-global-mode 1))

(add-hook 'next-error-hook #'pulsar-pulse-line)

(add-hook 'minibuffer-setup-hook #'pulsar-pulse-line)

;; integration with the `consult' package:
(add-hook 'consult-after-jump-hook #'pulsar-recenter-top)
(add-hook 'consult-after-jump-hook #'pulsar-reveal-entry)

;; integration with the built-in `imenu':
(add-hook 'imenu-after-jump-hook #'pulsar-recenter-top)
(add-hook 'imenu-after-jump-hook #'pulsar-reveal-entry)

(leaf switch-window
  :straight (switch-window
             :type git
             :host github
             :repo "dimitri/switch-window"
             :fetch t)
  :bind
  ("C-x w" . switch-window)
  :config
  (setq switch-window-shortcut-style 'qwerty
        switch-window-timeout nil
        switch-window-threshold 2))

(leaf avy
  :straight (avy
             :type git
             :host github
             :repo "abo-abo/avy"
             :fetch t)
  :config
  ;; core behavior
  (setq avy-background nil        ; do not dim background
        avy-all-windows t         ; jump across windows
        avy-style 'at-full        ; full precision hints
        avy-timeout-seconds 0.4)

  (setq avy-keys (string-to-list "aoeuidhtns")) ; home row Dvorak

  ;; minimal neutral look
  (custom-set-faces
   '(avy-lead-face   ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-0 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-1 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-2 ((t (:foreground "#000000" :background "#cccccc" :weight normal)))))

  ;; dispatch — surgical actions mid-jump
  (setq avy-dispatch-alist
        '((?k . avy-kill-region)
          (?y . avy-copy-region)
          (?c . avy-kill-ring-save)))
)

(leaf move-text
  :straight (move-text
             :type git
             :host github
             :repo "emacsfodder/move-text"
             :fetch t)
  :bind
  ("M-<up>"   . move-text-up)
  ("M-<down>" . move-text-down)
  :config
  ;; Evil integration
  (define-key evil-normal-state-map (kbd "M-<up>")   #'move-text-up)
  (define-key evil-normal-state-map (kbd "M-<down>") #'move-text-down)
  (define-key evil-visual-state-map (kbd "M-<up>")   #'move-text-up)
  (define-key evil-visual-state-map (kbd "M-<down>") #'move-text-down))

(leaf yasnippet
  :straight t
  :hook (after-init . yas-global-mode)
  :config
  ;; snippet roots
  (setq yas-snippet-dirs
        (list (expand-file-name "snippets" "~/.config/emacs/")
              (expand-file-name "snippets"
                                (file-name-directory (locate-library "yasnippet")))))

  ;; use AFTER load so warnings vanish
  (with-eval-after-load 'yasnippet
    (yas-reload-all))

  ;; expansion key
  (define-key yas-minor-mode-map (kbd "TAB") #'yas-expand))

(leaf auto-yasnippet
  :straight (auto-yasnippet
             :type git
             :host github
             :repo "abo-abo/auto-yasnippet")
  :bind
  ("C-c y w" . aya-create)
  ("C-c y e" . aya-expand)
  :config
  (setq aya-persist-snippets t
        aya-persist-directory (expand-file-name "auto-snippets" "~/.config/emacs/")))

(leaf dap-mode
  :straight (dap-mode
             :host github
             :repo "emacs-lsp/dap-mode")
  :after lsp-mode
  :config
  ;; core engine
  (dap-mode 1)
  (dap-ui-mode 1)

  ;; auto configuration
  (setq dap-auto-configure-mode t
        dap-auto-configure-features '(sessions locals controls tooltip))

  ;; muscle-memory debugging keys
  (define-key dap-mode-map (kbd "C-c d d") #'dap-debug)
  (define-key dap-mode-map (kbd "C-c d b") #'dap-breakpoint-toggle)
  (define-key dap-mode-map (kbd "C-c d n") #'dap-continue)
  (define-key dap-mode-map (kbd "C-c d s") #'dap-step-in)
  (define-key dap-mode-map (kbd "C-c d o") #'dap-step-out))

(leaf which-key
  :straight (which-key
             :host github
             :repo "justbur/emacs-which-key")
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.4
        which-key-max-description-length 40))

(leaf flycheck
  :straight (flycheck
             :host github
             :repo "flycheck/flycheck")
  :hook (after-init . global-flycheck-mode)
  :config
  (global-flycheck-mode 1)

  ;; Monochrome diagnosis
  (custom-set-faces
   '(flycheck-error   ((t (:underline (:style wave :color "#000000")))))
   '(flycheck-warning ((t (:underline (:style wave :color "#000000")))))
   '(flycheck-info    ((t (:underline (:style wave :color "#000000")))))))

(leaf projectile
  :straight (projectile
             :host github
             :repo "bbatsov/projectile")
  :init
  ;; Prefix before loading
  (setq projectile-keymap-prefix (kbd "C-c p"))
  :config
  (projectile-mode +1)

  ;; Search realms in your universe
  (setq projectile-project-search-path
        '("~/Projects"
          "~/Shapeless-Links"
          "~/AeonCore"))

  (setq projectile-enable-caching t
        projectile-completion-system 'default)

  ;; Use ripgrep for indexing if available
  (when (executable-find "rg")
    (setq projectile-generic-command
          "rg -0 --files --color=never --hidden --ignore-vcs"))

  ;; Bindings forged for motion
  (define-key projectile-mode-map (kbd "C-c p f") #'projectile-find-file)
  (define-key projectile-mode-map (kbd "C-c p p") #'projectile-switch-project)
  (define-key projectile-mode-map (kbd "C-c p b") #'projectile-switch-to-buffer)

  ;; monochrome modeline segment
  (custom-set-faces
   '(projectile-mode-line ((t (:foreground "#000000" :weight bold)))))

  )

(leaf compat
  :straight (compat
             :type git
             :host github
             :repo "emacs-straight/compat")
  :require compat)

(leaf org-timeblock
  :straight (org-timeblock
             :type git
             :host github
             :repo "ichernyshovvv/org-timeblock")
  :after org
  :commands (org-timeblock)
  :config
  (setq org-timeblock-files '("~/Shapeless-Links/"
                              "~/Projects/"))
  (setq org-timeblock-span 3))

(leaf orgit-file
  :straight (orgit-file
             :type git
             :host github
             :repo "gggion/orgit-file")
  :after (orgit magit org)

  :config
  ;; Now variables exist — safe to set
  (setq orgit-file-link-to-file-use-orgit 'blob-buffers-only)
  (setq orgit-file-abbreviate-revisions t)
  (setq orgit-file-export-text-fragments t)

  ;; Keybinding
  (define-key global-map (kbd "C-c g l") #'orgit-file-store))

(leaf magit-todos
  :straight (magit-todos
             :type git
             :host github
             :repo "alphapapa/magit-todos")
  :after magit
  :config
  (magit-todos-mode 1)

  ;; keyword spectrum
  (setq magit-todos-keywords '("TODO" "FIXME" "BUG" "NOTE"))

  ;; ignore noise
  (setq magit-todos-exclude-globs '("node_modules/*"
                                    "vendor/*"
                                    "*.min.js"))

  ;; carve a motion into magit-status
  (define-key magit-status-mode-map (kbd "j T")
    #'magit-todos-list))

(leaf modus-themes
  :straight (modus-themes
             :type git
             :host github
             :repo "protesilaos/modus-themes")
  :init
  (setq modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-org-blocks 'gray-background
        modus-themes-fringes 'intense)
  :config
  (load-theme 'modus-operandi :no-confirm)

  (defun shapeshift/monochrome-world ()
    "Pure black-on-white monochrome for everything."
    
    ;; Canvas
    (set-face-attribute 'default nil
                        :foreground "#000000"
                        :background "#ffffff")
    (set-face-attribute 'fringe nil :background "#ffffff" :foreground "#000000")
    (set-face-attribute 'mode-line nil :background "#ffffff" :foreground "#000000" :box nil)
    (set-face-attribute 'mode-line-inactive nil :background "#ffffff" :foreground "#000000" :box nil)

    ;; Org hierarchy
    (set-face-attribute 'org-document-title nil :foreground "#000000" :weight 'bold :height 2.0 :inherit nil)
    (set-face-attribute 'org-level-1 nil :foreground "#000000" :weight 'bold :height 1.80 :inherit nil)
    (set-face-attribute 'org-level-2 nil :foreground "#000000" :weight 'bold :height 1.60 :inherit nil)
    (set-face-attribute 'org-level-3 nil :foreground "#000000" :weight 'bold :height 1.40 :inherit nil)
    (set-face-attribute 'org-level-4 nil :foreground "#000000" :weight 'bold :height 1.20 :inherit nil)
    (set-face-attribute 'org-level-5 nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'org-level-6 nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'org-level-7 nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'org-level-8 nil :foreground "#000000" :weight 'bold :inherit nil)

    ;; Org elements
    (set-face-attribute 'org-link nil :underline nil :inherit nil :foreground "#000000")
    (set-face-attribute 'org-block nil :background "#f5f5f5" :foreground "#000000")
    (set-face-attribute 'org-block-begin-line nil :foreground "#000000" :background "#f5f5f5")
    (set-face-attribute 'org-block-end-line nil :foreground "#000000" :background "#f5f5f5")
    (set-face-attribute 'org-code nil :foreground "#000000" :background "#f5f5f5")
    (set-face-attribute 'org-verbatim nil :foreground "#000000" :background "#f5f5f5")
    (set-face-attribute 'org-meta-line nil :foreground "#000000")
    (set-face-attribute 'org-todo nil :foreground "#000000" :weight 'bold)
    (set-face-attribute 'org-done nil :foreground "#000000" :weight 'bold)

    ;; Code syntax highlighting
    (dolist (face '(font-lock-comment-face
                    font-lock-string-face
                    font-lock-keyword-face
                    font-lock-function-name-face
                    font-lock-variable-name-face
                    font-lock-type-face
                    font-lock-constant-face
                    font-lock-builtin-face
                    font-lock-warning-face
                    font-lock-doc-face))
      (set-face-attribute face nil :foreground "#000000" :inherit nil))

    ;; LaTeX faces
    (with-eval-after-load 'tex-mode
      (dolist (face '(font-latex-math-face
                      font-latex-script-char-face
                      font-latex-string-face
                      font-latex-warning-face
                      font-latex-sedate-face
                      font-latex-sectioning-0-face
                      font-latex-sectioning-1-face
                      font-latex-sectioning-2-face
                      font-latex-sectioning-3-face
                      font-latex-sectioning-4-face
                      font-latex-sectioning-5-face))
        (set-face-attribute face nil :foreground "#000000" :inherit nil)))

    ;; Dired
    (with-eval-after-load 'dired
      (dolist (face '(dired-directory
                      dired-symlink
                      dired-mark
                      dired-marked
                      dired-flagged
                      dired-warning
                      dired-perm-write
                      dired-special
                      dired-header
                      dired-ignored))
        (set-face-attribute face nil :foreground "#000000" :weight 'bold :inherit nil)))

    ;; Magit
    (with-eval-after-load 'magit
      (dolist (face '(magit-section-heading
                      magit-section-highlight
                      magit-branch-local
                      magit-branch-remote
                      magit-branch-current
                      magit-hash
                      magit-tag
                      magit-diff-added
                      magit-diff-removed
                      magit-diff-added-highlight
                      magit-diff-removed-highlight
                      magit-diff-context
                      magit-diff-context-highlight
                      magit-diff-hunk-heading
                      magit-diff-hunk-heading-highlight
                      magit-diff-file-heading
                      magit-diff-file-heading-highlight
                      magit-log-author
                      magit-log-date
                      magit-log-graph
                      magit-process-ok
                      magit-process-ng
                      magit-signature-good
                      magit-signature-bad
                      magit-signature-untrusted
                      magit-cherry-equivalent
                      magit-cherry-unmatched))
        (when (facep face)
          (set-face-attribute face nil :foreground "#000000" :background "#ffffff" :inherit nil))))

    ;; PDF-tools
    (with-eval-after-load 'pdf-view
      (setq pdf-view-midnight-colors '("#000000" . "#ffffff")))

    ;; Line numbers
    (when (facep 'line-number)
      (set-face-attribute 'line-number nil :foreground "#000000" :background "#ffffff")
      (set-face-attribute 'line-number-current-line nil :foreground "#000000" :background "#f5f5f5" :weight 'bold))

    ;; Highlighting
    (with-eval-after-load 'hl-line
      (set-face-attribute 'hl-line nil :background "#f5f5f5" :inherit nil))
    (set-face-attribute 'region nil :background "#e0e0e0" :foreground "#000000")
    (set-face-attribute 'highlight nil :background "#e0e0e0" :foreground "#000000")

    ;; Minibuffer
    (set-face-attribute 'minibuffer-prompt nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'completions-annotations nil :foreground "#000000" :inherit nil)
    (set-face-attribute 'completions-common-part nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'completions-first-difference nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'shadow nil :foreground "#000000" :inherit nil)
    (set-face-attribute 'help-key-binding nil :foreground "#000000" :weight 'bold :inherit nil)
    (when (facep 'completions-highlight)
      (set-face-attribute 'completions-highlight nil :foreground "#000000" :background "#f5f5f5" :inherit nil))
    (with-eval-after-load 'vertico
      (dolist (face '(vertico-current
                      vertico-group-title
                      vertico-group-separator
                      vertico-multiline))
        (when (facep face)
          (set-face-attribute face nil :foreground "#000000" :background "#f5f5f5" :inherit nil))))
    (with-eval-after-load 'orderless
      (set-face-attribute 'orderless-match-face-0 nil :foreground "#000000" :weight 'bold :inherit nil)
      (set-face-attribute 'orderless-match-face-1 nil :foreground "#000000" :weight 'bold :inherit nil)
      (set-face-attribute 'orderless-match-face-2 nil :foreground "#000000" :weight 'bold :inherit nil)
      (set-face-attribute 'orderless-match-face-3 nil :foreground "#000000" :weight 'bold :inherit nil))
    (with-eval-after-load 'ivy
      (dolist (face '(ivy-current-match
                      ivy-minibuffer-match-face-1
                      ivy-minibuffer-match-face-2
                      ivy-minibuffer-match-face-3
                      ivy-minibuffer-match-face-4
                      ivy-action
                      ivy-highlight-face
                      ivy-remote
                      ivy-subdir
                      ivy-virtual
                      ivy-confirm-face
                      ivy-match-required-face))
        (when (facep face)
          (set-face-attribute face nil :foreground "#000000" :weight 'bold :inherit nil))))
    (with-eval-after-load 'helm
      (dolist (face '(helm-selection
                      helm-match
                      helm-source-header
                      helm-visible-mark
                      helm-candidate-number
                      helm-separator
                      helm-M-x-key
                      helm-buffer-directory
                      helm-buffer-file
                      helm-buffer-process
                      helm-ff-directory
                      helm-ff-file
                      helm-grep-match))
        (when (facep face)
          (set-face-attribute face nil :foreground "#000000" :background "#ffffff" :weight 'bold :inherit nil))))

    ;; Org-roam-ui sync
    (when (and (featurep 'org-roam-ui) org-roam-ui-mode)
      (org-roam-ui--update-theme)))

  ;; Apply immediately
  (shapeshift/monochrome-world)

  ;; Persist after theme reload
  (advice-add 'load-theme :after
              (lambda (&rest _) (shapeshift/monochrome-world))))

;; Ensure org-roam-ui picks up the monochrome theme
(leaf org-roam-ui
 :straight (org-roam-ui
           :type git
             :host github
             :repo "org-roam/org-roam-ui"
             :files ("*.el" "out"))
  :after org-roam
  :config
  (require 'hl-line)
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t)
  
  (add-hook 'after-init-hook #'org-roam-ui-mode)
  
  (defun my/org-roam-ui-sync-theme (&rest _)
    (when (and (featurep 'org-roam-ui) org-roam-ui-mode)
      (org-roam-ui--update-theme)))
  
  (advice-add 'load-theme :after #'my/org-roam-ui-sync-theme)
 (advice-add 'shapeshift/monochrome-world :after #'my/org-roam-ui-sync-theme))

(leaf org-transclusion
  :straight (org-transclusion
             :type git
             :host github
             :repo "nobiot/org-transclusion")
  :after org
  :config
  ;; Auto-enable in Org buffers (optional; comment out if too much)
  (add-hook 'org-mode-hook #'org-transclusion-mode)

  ;; Quick keybindings for operations
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c t a") #'org-transclusion-add)
    (define-key org-mode-map (kbd "C-c t u") #'org-transclusion-refresh)))

(leaf denote-explore
  :straight (denote-explore
             :type git
             :host github
             :repo "pprevos/denote-explore")
  :after denote
  :config
  (global-set-key (kbd "C-c d e") #'denote-explore)
  (global-set-key (kbd "C-c d b") #'denote-explore-backlinks))

(leaf consult-denote
  :straight (consult-denote
             :type git
             :host github
             :repo "protesilaos/consult-denote")
  :after (denote consult)
  :config
  ;; Use Consult for completing/jumping across Denote notes
  (global-set-key (kbd "C-c d f") #'consult-denote)

  ;; Optional: narrow by keyword/tag quickly
  (global-set-key (kbd "C-c d F") #'consult-denote-file))

;; ───────────────────────────────────────────────────────────────
;; CONSULT — the high-precision jump engine
;; ───────────────────────────────────────────────────────────────
(leaf consult
  :straight (consult
             :type git
             :host github
             :repo "minad/consult")
  :bind
  (("C-s"     . consult-line)              ;; search inside buffer
   ("C-c f"   . consult-find)              ;; find files
   ("C-c g"   . consult-git-grep)          ;; ripgrep
   ("C-x b"   . consult-buffer)            ;; buffer switcher
   ("C-x r b" . consult-bookmark)          ;; bookmarks
   ))

;; ───────────────────────────────────────────────────────────────
;; EMBARK — the action layer (right-click for the keyboard age)
;; ───────────────────────────────────────────────────────────────
(leaf embark
  :straight (embark
             :type git
             :host github
             :repo "oantolin/embark")
  :bind
  (("C-." . embark-act)         ;; think: context menu, immediate action
   ("C-;" . embark-dwim)        ;; run best action automatically
   ("C-h B" . embark-bindings)) ;; see keymaps

  :config
  ;; nicer popups
  (setq embark-prompter 'embark-keymap-prompter))

;; live annotations for consult
(leaf embark-consult
  :straight (embark-consult
             :type git
             :host github
             :repo "oantolin/embark")
  :after (embark consult)
  :config
  (embark-consult-mode 1))
(with-eval-after-load 'consult
  (define-key shapeshifter-leader-map (kbd "u") #'consult-buffer)
  (define-key shapeshifter-leader-map (kbd "f") #'consult-find)
  (define-key shapeshifter-leader-map (kbd "b") #'consult-buffer)
  (define-key shapeshifter-leader-map (kbd "s") #'consult-ripgrep)
  (define-key shapeshifter-leader-map (kbd "l") #'consult-line))

(leaf speed-type
  :straight (speed-type
             :type git
             :host github
             :repo "dakra/speed-type")
  :after evil

  :config
  ;; Directory for speed-type corpuses.
  (let ((speed-dir "~/.config/emacs/lib/speed-type"))
    (unless (file-directory-p speed-dir)
      (make-directory speed-dir t))
    ;; Default corpus file; you can replace or add more later.
    (setq speed-type-gb-file (expand-file-name "gb.txt" speed-dir)))

  ;; Evil leader bindings — "T" for typing drills
  (define-key evil-normal-state-map (kbd "SPC T t") #'speed-type-text)
  (define-key evil-normal-state-map (kbd "SPC T b") #'speed-type-buffer)
  (define-key evil-normal-state-map (kbd "SPC T r") #'speed-type-region)
  (define-key evil-normal-state-map (kbd "SPC T d") #'speed-type-debug))

(leaf vterm
  :straight (vterm
             :type git
             :host github
             :repo "akermu/emacs-libvterm")
  :after evil
  :config
  ;; Optional: vterm buffer directory
  (setq vterm-buffer-name "vterm")  ;; default name for new terminals

  ;; Ensure executable exists
  (unless (executable-find "vterm")
    (message "⚠️ vterm executable not found. Make sure libvterm is compiled."))

  ;; Evil leader bindings — "V" for terminal
  (define-key evil-normal-state-map (kbd "SPC V v") #'vterm)
  (define-key evil-normal-state-map (kbd "SPC V s") 
    (lambda () (interactive)
      (vterm (generate-new-buffer-name "vterm"))))
  (define-key evil-normal-state-map (kbd "SPC V r") #'vterm-send-receive))
