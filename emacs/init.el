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

;;; tree.el --- Managed Emacs configuration through org files
;; Copyright (C) 2025
;; Author: Internal implementation
;;; Commentary:
;; This version works exclusively with leaf package declarations.
;; Remote functionality has been removed.
(require 'cl-lib)
(require 'ob-core)
;;; Code:

(defvar tree-packages '()
    "List of packages that should be installed.")

  (defvar tree--booting nil
    "Non-nil when running inside `tree-boot'.")

  (defvar tree--boot-phase :loading
    "Internal boot phase for the splash screen.
  Possible values: :compiling or :loading.")

  (defvar tree--boot-errors '()
    "List of compile / loading errors encountered during tree boot.")

  (defcustom tree-wrap-statements-in-condition t
    "Wrap code in condition statements."
    :type 'boolean
    :group 'tree)

(defcustom tree-leaf-keywords
  '("after" "demand" "ensure" "config" "init" "bind" "bind*" "hook" "general" "custom" "defer" "requires" "straight")
  "List of `leaf' keywords that can be used.
The keywords are case sensitive. If the tag ends with an
underscore, it will be replaced with a asterisk."
  :type 'list
  :group 'tree)
  
  (defcustom tree-output-directory (expand-file-name "tree" user-emacs-directory)
    "Directory where the tangled Elisp files are stored."
    :type 'string
    :group 'tree)

  (defcustom tree-org-directory (expand-file-name "org" user-emacs-directory)
    "Directory where the Org files are stored."
    :type 'string
    :group 'tree)

  (defcustom tree-force-compile nil
    "Force compilation of Org files, even if the Elisp file is newer
  than the Org file."
    :type 'boolean
    :group 'tree)

(defun tree-indent (string n)
  "Indent STRING by N spaces."
  (let ((indentation (make-string n ?\s)))
    (replace-regexp-in-string "^" indentation string)))

(defun tree-plist-keys (plist)
  "Return the keys of PLIST as a list."
  (let ((keys '()))
    (while plist
      (push (car plist) keys)
      (setq plist (cddr plist)))
    (nreverse keys)))

(defun tree-find-property (property)
  "Find PROPERTY in the current Org element or any ancestor element."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property property (org-element-context)))
            (org-up-element))
          (intern (org-element-property property (org-element-context))))
      (error nil))))

(defun tree-find-tags ()
  "Find tags in the current Org element or any ancestor element."
  (save-excursion
    (condition-case nil
        (progn
          (while (not (org-element-property :tags (org-element-lineage (org-element-context) '(headline) t)))
            (org-up-element))
          (org-element-property :tags (org-element-lineage (org-element-context) '(headline) t)))
      (error nil))))

(defun tree-find-tag ()
  "Find a `leaf' tag in the current Org element or any ancestor element."
  (let* ((keywords tree-leaf-keywords)
         (tag (car (seq-filter (lambda (tag) (member tag keywords)) (tree-find-tags)))))
    (when tag
      (replace-regexp-in-string "_" "-"
                                (replace-regexp-in-string "_$" "*" tag)))))

(defun tree-find-package ()
  "Find a `leaf' package in the current Org element or any ancestor element."
  (or (tree-find-property :PACKAGE)
      (tree-find-property :LEAF_PACKAGE)
      (tree-find-property :LEAF-PACKAGE)))

(defun tree-find-after ()
  "Find a `leaf' :after property in the current Org element or any ancestor element."
  (when-let* ((after (tree-find-property :AFTER)))
    (prin1-to-string (read (symbol-name after)))))

(defun tree-find-demand ()
  "Find a `leaf' :demand property in the current Org element or any ancestor element."
  (when-let* ((demand (tree-find-property :DEMAND)))
    (prin1-to-string (read (symbol-name demand)))))

(defun tree-find-ensure ()
  "Find a `leaf' :ensure property in the current Org element or any ancestor element."
  (when-let* ((ensure (tree-find-property :ENSURE)))
    (prin1-to-string (read (symbol-name ensure)))))

(defun tree-find-defer ()
  "Find a `leaf' :defer property in the current Org element or any ancestor element."
  (when-let* ((defer (tree-find-property :DEFER)))
    (prin1-to-string (read (symbol-name defer)))))

(defun tree-find-requires ()
  "Find a `leaf' :requires property in the current Org element or any ancestor element."
  (when-let* ((requires (tree-find-property :REQUIRES)))
    (prin1-to-string (read (symbol-name requires)))))

(defun tree-find-keyword ()
  "Find a `leaf' keyword in the current Org element or any ancestor element."
  (when-let* ((keyword (tree-find-property :KEYWORD)))
    (replace-regexp-in-string "^:" "" (symbol-name keyword))))

(defun tree-get-leaf-package ()
  "Return the package name and Leaf keyword for a package."
  (when-let* ((package (tree-find-package))
              (keyword (or (tree-find-keyword)
                          (tree-find-tag))))
    (list package keyword)))

(defun tree-find-straight ()
"Find a `leaf' :straight property in the current Org element or any ancestor element."
(when-let* ((straight (tree-find-property :STRAIGHT)))
  (prin1-to-string (read (symbol-name straight)))))

(defun tree-file-properties (file)
  "Return all properties from an org FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let (properties)
      (goto-char (point-min))
      (while (re-search-forward "^\\(?:;;[ \t]*\\)?#\\+\\([A-Za-z0-9_]+\\):[ \t]*\\(.*\\)$" nil t)
        (let ((key (intern (downcase (match-string 1))))
              (value (match-string 2)))
          (push (cons key value) properties)))
      properties)))

(defun tree-file-priority (file)
  "Return the priority of an org FILE.
If no priority is set, return 10."
  (let ((priority (alist-get 'priority (tree-file-properties file) "10")))
    (if (string-match-p "^[0-9]+$" priority)
        (string-to-number priority)
      10)))

(defun tree-file-lexical-binding (file)
  "Return the lexical-binding of an org FILE.
If no lexical-binding is set, return t."
  (let ((lexical-binding (alist-get 'lexical_binding (tree-file-properties file) "t")))
    (if (string= lexical-binding "nil")
        nil
      t)))

(defun tree-get-files (extension directory)
  "Return all files with EXTENSION in DIRECTORY.
The files are sorted by priority."
  (when (file-exists-p directory)
    (let* ((files (directory-files-recursively directory extension)))
      (sort files (lambda (a b) (< (tree-file-priority a)
                                   (tree-file-priority b)))))))

(defun tree-safe-read (string file &optional line)
  "Read STRING and return the result.
If STRING is not a valid Elisp form, return nil.
FILE is the file name of the Org file.
LINE is the line number of the Org file.
If read fails, display a warning."
  (condition-case err
      (read string)
    (error
     (display-warning
      'tree
      (if line
          (format "failed to read body of %s:%s" file line)
        (format "failed to read body of %s" file))
      :error)
     nil)))

(defun tree-wrap-in-condition (file part)
  "Wrap PART in a `condition-case' form.
FILE is the file name of the Org file."
  (let* ((body (plist-get part :body))
         (line (plist-get part :line))
         (expression-string (string-trim-right body))
         (expression (tree-safe-read (format "(progn\n%s)" expression-string) file line)))
    (if tree-wrap-statements-in-condition
        (pp-to-string
         `(condition-case err
              ,expression
            (error
             (add-to-list 'tree--boot-errors
                          (list :file ,(format "%s" file)
                                :line ,line
                                :message (error-message-string err)))
             (unless tree--booting
               (display-warning
                'tree
                (format "Error loading %s:%s - %s"
                        ,(format "%s" file)
                        ,line
                        (error-message-string err))
                :error)))))
      expression-string)))

(defun tree-merge-bodies (file xs)
  "Merge the bodies of a list of `leaf' statements.
FILE is the file name of the Org file.
XS is a list of `leaf' statements."
  (let ((result '()))
    (dolist (x xs)
      (let* ((body (plist-get x :body))
             (line (plist-get x :line))
             (result-body (tree-safe-read body file line)))
        (when result-body
          (setq result (append result result-body)))))
    (when result
      (prin1-to-string result))))

(defun tree-build-leaf-string (package-name package file)
    "Build a `leaf' block for PACKAGE-NAME in string format.
  PACKAGE is the package plist.
  FILE is the Org file name."
    (concat
     (string-trim-right
      (concat (format "(leaf %s" package-name)
              ;; Leaf uses :ensure
;; Leaf supports :straight
(when-let* ((straight (plist-get (car (plist-get package :straight)) :body)))
  (format "\n  :straight %s" straight))
              (when-let* ((ensure (plist-get (car (plist-get package :ensure)) :body)))
                (format "\n  :ensure %s" ensure))
              ;; Leaf supports :require (not :requires)
              (when-let* ((requires (plist-get (car (plist-get package :requires)) :body)))
                (format "\n  :require %s" requires))
              ;; Leaf supports :after
              (when-let* ((after (plist-get (car (plist-get package :after)) :body)))
                (format "\n  :after %s" after))
              ;; Leaf supports :defer
              (when-let* ((defer (plist-get (car (plist-get package :defer)) :body)))
                (format "\n  :defer %s" defer))
              ;; Leaf supports :demand
              (when-let* ((demand (plist-get (car (plist-get package :demand)) :body)))
                (format "\n  :demand %s" demand))
              ;; Leaf supports :bind*
              (when-let* ((bind* (tree-merge-bodies file (plist-get package :bind*))))
                (format "\n  :bind*\n%s" (tree-indent bind* 2)))
              ;; Leaf supports :bind
              (when-let* ((bind (tree-merge-bodies file (plist-get package :bind))))
                (format "\n  :bind\n%s" (tree-indent bind 2)))
              ;; Leaf supports :hook
              (when-let* ((hook (tree-merge-bodies file (plist-get package :hook))))
                (format "\n  :hook\n%s" (tree-indent hook 2)))
              ;; Leaf supports :init
              (when-let* ((init (plist-get package :init)))
                (format "\n  :init\n%s" (tree-indent (string-join (mapcar (lambda (x) (tree-wrap-in-condition file x)) init) "\n") 2)))
              ;; Leaf supports :custom
              (when-let* ((custom (plist-get package :custom)))
                (let ((custom-forms (mapcar (lambda (part) 
                                             (string-trim (plist-get part :body)))
                                           custom)))
                  (format "\n  :custom\n  %s" (string-join custom-forms "\n  "))))
              ;; Leaf supports :config
              (when-let* ((config (plist-get package :config)))
                (format "\n  :config\n%s" (tree-indent (string-join (mapcar (lambda (x) (tree-wrap-in-condition file x)) config) "\n") 2)))))
     ")\n\n"))
  (defun tree-build-leaf (file package-name)
    "Build a `leaf' block for PACKAGE-NAME in string format.
  FILE is the Org file name.
  PACKAGE-NAME is the name of the package."
    (when-let* ((package (plist-get tree-packages package-name)))
      (when (not (equal package-name (intern "nil")))
        (let ((package-string (tree-build-leaf-string package-name package file)))
          (when (tree-safe-read package-string file)
            package-string)))))

  (defun tree-build-leafs (file)
    "Build a string of `leaf' blocks.
  The resulting string contains all packages in `tree-packages'.
  FILE is the file name of the Org file."
    (let ((package-names (tree-plist-keys tree-packages))
          (result ""))
      (dolist (package-name package-names)
        (setq result (concat result (tree-build-leaf file package-name))))
      result))

(defun tree-put-package-parameter (package-name parameter value)
  "Put a parameter in the `tree-packages' plist.
PACKAGE-NAME is the name of the package.
PARAMETER is the parameter to set.
VALUE is the value to set."
  (setq tree-packages
        (plist-put
         tree-packages
         package-name
         (plist-put (plist-get tree-packages package-name)
                    parameter
                    value))))

(defun tree-add-package (package body element)
  "Execute a block of Leaf code with org-babel.
PACKAGE is a list of the package name and parameter.
BODY is the body of the source block.
ELEMENT is the org element of the source block."
  (let* ((begin (org-element-property :begin element))
         (line (line-number-at-pos begin))
         (package-name (car package))
         (package-parameter (intern (concat ":" (car (cdr package)))))
         (previous-body (plist-get (plist-get tree-packages package-name) package-parameter))
         (value (append previous-body `((:body ,body :line ,line)))))
    (tree-put-package-parameter package-name package-parameter value)
    nil))

(defun tree-concatenate-source-blocks (file)
  "Concatenate all source blocks in FILE and return the results as a string."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((results '()))
      (org-map-entries
       (lambda ()
         (let ((line (line-number-at-pos (org-element-property :begin (org-element-context)))))
           (when-let* ((package-name (tree-find-package))
                       (package (org-element-property :PACKAGE (org-element-context))))
             (tree-put-package-parameter package-name :package line))
           (when-let* ((package-name (tree-find-package))
                       (after (tree-find-after)))
             (tree-put-package-parameter package-name :after `((:body ,after :line ,line))))
           (when-let* ((package-name (tree-find-package))
                       (demand (tree-find-demand)))
             (tree-put-package-parameter package-name :demand `((:body ,demand :line ,line))))
           (when-let* ((package-name (tree-find-package))
                       (ensure (tree-find-ensure)))
             (tree-put-package-parameter package-name :ensure `((:body ,ensure :line ,line))))
           (when-let* ((package-name (tree-find-package))
                       (defer (tree-find-defer)))
             (tree-put-package-parameter package-name :defer `((:body ,defer :line ,line))))
           (when-let* ((package-name (tree-find-package))
                       (requires (tree-find-requires)))
             (tree-put-package-parameter package-name :requires `((:body ,requires :line ,line))))
           (when-let* ((package-name (tree-find-package))
                       (straight (tree-find-straight)))
             (tree-put-package-parameter package-name :straight `((:body ,straight :line ,line)))))))
      (org-babel-map-src-blocks nil
        (let ((body (org-element-property :value (org-element-context)))
              (line (line-number-at-pos (org-element-property :begin (org-element-context))))
              (language (org-element-property :language (org-element-context))))
          (when (string= language "emacs-lisp")
            (if-let* ((package (tree-get-leaf-package)))
                (tree-add-package package body (org-element-context))
              (when (stringp body)
                (push (tree-wrap-in-condition file `(:body ,body :line ,line))
                      results))))))
      (mapconcat 'identity (reverse results) "\n"))))

(defun tree-output-file-name (file)
  "Return the name of the output Elisp file for FILE."
  (if (string-prefix-p
       (expand-file-name tree-org-directory)
       (expand-file-name file))
      (expand-file-name
       (concat (file-name-as-directory tree-output-directory)
               (file-name-sans-extension (substring file (length (expand-file-name tree-org-directory))))
               ".el"))
    (error "File is not in tree-org-directory")))

(defun tree-compile-file (file)
  "Compile FILE to Elisp.
FILE is an Org file.
The output Elisp file is stored in `tree-output-directory'."
  (unless (file-exists-p file)
    (error "File to tangle does not exist: %s" file))
  (unless (file-exists-p tree-output-directory)
    (make-directory tree-output-directory t))
  (let ((output-file (tree-output-file-name file)))
    (make-directory (file-name-directory output-file) t)
    (when (or tree-force-compile
              (file-newer-than-file-p file output-file))
      (message "Tree: Compiling %s" file)
      (let* ((tree-packages nil)
             (source (tree-concatenate-source-blocks file))
             (output (concat source "\n" (tree-build-leafs file))))
        (with-temp-file output-file
          (when (tree-file-lexical-binding file)
            (insert ";;; -*- lexical-binding: t -*-\n"))
          (dolist (property (tree-file-properties file))
            (insert (format ";; #+%s: %s\n\n"
                            (upcase (symbol-name (car property)))
                            (cdr property))))
          (insert output)))
      (when (file-exists-p output-file)
        (set-file-times output-file))
      output-file)))

(defun tree-compile-directory ()
  "Compile all Org files in `tree-org-directory' to Elisp.
All files will be outputted to `tree-output-directory'."
  (let* ((splash (when tree--booting (tree-show-splash)))
         (files (tree-get-files "^[^#]*\\.org$" tree-org-directory))
         (compiled '())
         (current 0)
         (total (length files)))
    (dolist (file files)
      (setq current (1+ current))
      (when splash
        (tree-splash-update-progress splash current total file))
      (when-let* ((output (tree-compile-file file)))
        (push output compiled)))
    compiled))

(defun tree-load-file (file)
  "Load FILE."
  (let ((inhibit-message t))
    (if (load (expand-file-name file) nil t)
        (message "Tree: Loaded %s" file)
      (message "Tree: Failed to load %s" file))))

(defun tree-load-directory ()
  "Load all compiled Elisp files from `tree-output-directory'."
  (let* ((splash (when tree--booting (tree-show-splash)))
         (initial-gc-cons-threshold gc-cons-threshold)
         (files (tree-get-files "^[^#]*\\.el$" tree-output-directory))
         (total (length files))
         (current 0))
    (setq gc-cons-threshold (* 1024 1024 100))
    (dolist (file files)
      (condition-case err
          (progn
            (setq current (1+ current))
            (when splash
              (tree-splash-update-progress splash current total file))
            (tree-load-file file))
        (error
         (add-to-list 'tree--boot-errors
                      (list :file (format "%s" file)
                            :line 1
                            :message (error-message-string err)))
         (unless tree--booting
           (display-warning
            'tree
            (format "Error loading %s:%s - %s"
                    (format "%s" file)
                    1
                    (error-message-string err))
            :error)))))
    (tree-splash-update-progress splash total total nil)
    (setq gc-cons-threshold initial-gc-cons-threshold)
    nil))

(defun tree-reload ()
  "Compile and load all Org files."
  (interactive)
  (dolist (compiled-file (tree-compile-directory))
    (tree-load-file compiled-file)))

(defun tree-reload-current-buffer ()
  "Compile and load current Org file."
  (interactive)
  (let ((tree-force-compile t))
    (when-let* ((compiled-file (tree-compile-file (buffer-file-name (current-buffer)))))
      (tree-load-file compiled-file))))

(defun tree-preview ()
  "Compile the current buffer and display the result in *tree preview*."
  (interactive)
  (let* ((buffer (get-buffer-create "*tree preview*"))
         (_ (display-buffer buffer))
         (tree-wrap-statements-in-condition nil)
         (file (buffer-file-name (current-buffer)))
         (tree-packages nil)
         (source (tree-concatenate-source-blocks file))
         (output (concat source "\n" (tree-build-leafs file))))
    (with-current-buffer buffer
      (emacs-lisp-mode)
      (read-only-mode 1)
      (save-excursion
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert output)
          (goto-char (point-min)))))))

(define-minor-mode tree-preview-mode
  "Preview the current buffer as elisp."
  :lighter " tree-preview"
  (if tree-preview-mode
      (add-hook 'after-save-hook 'tree-preview nil t)
    (remove-hook 'after-save-hook 'tree-preview t)))

(defun tree-show-splash ()
  "Show the tree loading splash screen."
  (let ((buf (get-buffer-create "*Tree Loading*")))
    (with-current-buffer buf
      (erase-buffer)
      (org-mode)
      ;; Add keybinding to kill buffer with Enter
      (local-set-key (kbd "RET") 'tree-kill-splash)
      (local-set-key (kbd "<return>") 'tree-kill-splash))
    (switch-to-buffer buf)
    buf))

(defun tree-kill-splash ()
  "Kill the Tree splash screen buffer."
  (interactive)
  (when (string= (buffer-name) "*Tree Loading*")
    (kill-buffer (current-buffer))))

(defun tree-splash-update-progress (buf current total file)
  "Update the splash screen progress.
BUF is the splash buffer.
CURRENT is the current file number.
TOTAL is the total number of files.
FILE is the current file being processed."
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (let ((inhibit-read-only t)
            (label (pcase tree--boot-phase
                     (:compiling "Compiling")
                     (:loading   "Loading")
                     (_          "Processing"))))
        (erase-buffer)
        (insert "TREE")
        (insert (make-string 10 ?\n))
        (insert (format "[ %d / %d ]\n\n"
                        current total))
        (insert (tree-progress-bar-fancy current total 54))
        (insert "\n\n")
        (if file
            (insert (format "%s: %s\n" label file))
          (insert "\n"))
        (center-region (point-min) (point-max))
        (when tree--boot-errors
          (insert "\nErrors encountered:\n\n"))
        (dolist (e tree--boot-errors)
          (insert (format "[[%s::%s][%s:%s]]\n"
                          (plist-get e :file)
                          (plist-get e :line)
                          (plist-get e :file)
                          (plist-get e :line)))
          (insert (propertize (format " ⌞ %s\n" (plist-get e :message))
                              'face 'error)))
        (insert "\n\n")
        (insert (propertize "Press ENTER to dismiss" 'face 'shadow))
        (center-line)
        (redisplay)
        (unless file
          (org-mode)
          ;; Re-bind keys after org-mode resets them
          (local-set-key (kbd "RET") 'tree-kill-splash)
          (local-set-key (kbd "<return>") 'tree-kill-splash))))))

(defun tree-progress-bar-fancy (current total width)
  "Create a fancy progress bar.
CURRENT is the current progress.
TOTAL is the total amount.
WIDTH is the width of the progress bar."
  (let* ((ratio (/ (float current) total))
         (done (floor (* ratio width)))
         (todo (- width done)))
    (format "┌%s┐\n│%s%s│\n└%s┘"
            (make-string width ?─)
            (make-string done ?█)
            (make-string todo ?·)
            (make-string width ?─))))

(defun tree-boot ()
  "Compile and then load all Org files, showing a splash screen."
  (interactive)
  (let ((tree--booting t))
    (setq tree--boot-errors '())
    (let ((tree--boot-phase :compiling))
      (tree-compile-directory))
    (let ((tree--boot-phase :loading))
      (tree-load-directory))))

;; Initialize tree
(setq tree-org-directory           (expand-file-name "org" user-emacs-directory)
      tree-output-directory        (expand-file-name "tree" user-emacs-directory))
(tree-boot)
(add-hook 'org-mode-hook #'tree-preview-mode)

(provide 'tree)
;;; tree.el ends here

(defun tree/auto-compile-and-reload ()
  "Auto-compile and reload when an Org file in tree-org-directory is saved."
  (when (and buffer-file-name
             (file-in-directory-p buffer-file-name tree-org-directory)
             (string-suffix-p ".org" buffer-file-name))
    (message "Tree: Compiling and reloading %s…" (file-name-nondirectory buffer-file-name))
    (condition-case err
        (let ((tree-force-compile t))
          (when-let ((compiled-file (tree-compile-file buffer-file-name)))
            (tree-load-file compiled-file)
            (message "Tree: Reload complete ✓")))
      (error
       (display-warning
        'tree 
        (format "Failed to compile/reload: %s" (error-message-string err)) 
        :error)))))

(add-hook 'after-save-hook #'tree/auto-compile-and-reload)

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

;;────────────────────────────────────────────────────────────
;; Denote — .live System with Silos & Formats Separation (ENHANCED)
;;────────────────────────────────────────────────────────────

;;────────────────────────────────────────────────────────────
;; Org-ID — persistent identity
;;────────────────────────────────────────────────────────────
(leaf org-id
  :after org
  :config
  (setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id))

;;────────────────────────────────────────────────────────────
;; Master Directory Configuration
;;────────────────────────────────────────────────────────────
(defvar shapeshift/denote-master-dir "~/testing-manuscripts"
  "Master directory containing silos/ and formats/ subdirectories.")

(defvar shapeshift/denote-silos-dir nil
  "Silos directory where .live files are created.")

(defvar shapeshift/denote-formats-dir nil
  "Formats directory for exported files.")

;; Initialize directory structure
(setq shapeshift/denote-silos-dir 
      (expand-file-name "silos" shapeshift/denote-master-dir))
(setq shapeshift/denote-formats-dir 
      (expand-file-name "formats" shapeshift/denote-master-dir))

;; Ensure directory structure exists
(unless (file-directory-p shapeshift/denote-master-dir)
  (make-directory shapeshift/denote-master-dir t))
(unless (file-directory-p shapeshift/denote-silos-dir)
  (make-directory shapeshift/denote-silos-dir t))
(unless (file-directory-p shapeshift/denote-formats-dir)
  (make-directory shapeshift/denote-formats-dir t))

;;────────────────────────────────────────────────────────────
;; Org-Roam — neural map engine
;;────────────────────────────────────────────────────────────
(leaf org-roam
  :straight (org-roam
             :type git
             :host github
             :repo "org-roam/org-roam")
  :after org
  :init
  ;; Point to silos directory
  (setq org-roam-directory (file-truename shapeshift/denote-silos-dir))
  (setq find-file-visit-truename t)
  (setq org-roam-v2-ack t)
  :config
  (org-roam-db-autosync-mode))

;;────────────────────────────────────────────────────────────
;; Denote Configuration with .live Extension
;;────────────────────────────────────────────────────────────
(leaf denote
  :straight t
  :after org
  :init
  ;; Use silos directory
  (setq denote-directory (expand-file-name shapeshift/denote-silos-dir))
  (setq denote-file-type 'org)
  (setq denote-date-format "%Y-%m-%d--%H-%M")
  ;; Always prompt for: title, keywords, silo (subdirectory), signature
  (setq denote-prompts '(title keywords subdirectory signature))
  (setq org-startup-with-inline-images nil)
  (setq org-startup-folded 'showall)
  
  :config
  (denote-rename-buffer-mode 1)
  
  (setq denote-link-backlinks-display-buffer-action
        '((display-buffer-reuse-window display-buffer-below-selected)
          (window-height . fit-window-to-buffer)))

  ;;────────── Auto-Silo Creation Logic (No Confirmation) ──────────
  (defun shapeshift/denote-auto-silo-prompt ()
    "Prompt for silo (1st level) and sub-silo (2nd level), creating automatically."
    (let* ((existing-silos 
            (seq-filter #'file-directory-p
                        (directory-files denote-directory t "^[^.]")))
           (silo-names (mapcar (lambda (dir) 
                                 (file-name-nondirectory dir))
                               existing-silos))
           (silo (completing-read "Silo (1st level): " silo-names nil nil))
           (silo-path (expand-file-name silo denote-directory)))
      
      ;; Create silo automatically if needed
      (unless (file-directory-p silo-path)
        (make-directory silo-path t)
        (message "Created silo: %s" silo))
      
      ;; Now prompt for sub-silo (2nd level subdirectory)
      (let* ((existing-subsilo 
              (seq-filter #'file-directory-p
                          (directory-files silo-path t "^[^.]")))
             (subsilo-names (mapcar (lambda (dir)
                                      (file-name-nondirectory dir))
                                    existing-subsilo))
             (subsilo (completing-read "Sub-silo (2nd level, optional): " 
                                       subsilo-names nil nil)))
        
        (if (string-empty-p subsilo)
            silo-path
          (let ((subsilo-path (expand-file-name subsilo silo-path)))
            ;; Create sub-silo automatically
            (unless (file-directory-p subsilo-path)
              (make-directory subsilo-path t)
              (message "Created sub-silo: %s/%s" silo subsilo))
            subsilo-path)))))
  
  (advice-add 'denote-subdirectory-prompt 
              :override #'shapeshift/denote-auto-silo-prompt)

  ;;────────── Two-Way Linking System ──────────
  (defvar shapeshift/source-buffer-for-linking nil
    "Buffer from which new note was created, for bidirectional linking.")
  
  (defun shapeshift/insert-bidirectional-link (source-file new-file)
    "Insert link to NEW-FILE in SOURCE-FILE and vice versa."
    (when (and source-file (file-exists-p source-file))
      ;; Insert link in source file pointing to new file
      (with-current-buffer (find-file-noselect source-file)
        (save-excursion
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert "\n** Related Notes\n")
          (org-insert-link nil (concat "id:" (org-id-get-create)) 
                           (format "Link to new note: %s" 
                                   (file-name-base new-file)))
          (insert "\n"))
        (save-buffer))
      
      ;; Insert link in new file pointing back to source
      (with-current-buffer (find-file-noselect new-file)
        (save-excursion
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert "\n** Related Notes\n")
          (org-insert-link nil (concat "id:" (org-id-get-create)) 
                           (format "Link from: %s" 
                                   (file-name-base source-file)))
          (insert "\n"))
        (save-buffer))))

  ;;────────── Enhanced File Creation with .live Extension ──────────
  (defun shapeshift/denote-capture-create-file ()
    "Create Denote file with .live extension, org-id, and bidirectional linking."
    (let* ((title (read-string "Title: "))
           (keywords (denote-keywords-prompt))
           (subdir (shapeshift/denote-auto-silo-prompt))
           (signature (read-string "Signature (optional): " nil nil ""))
           (date (current-time))
           (id (format-time-string denote-date-format date))
           (date-formatted (format-time-string denote-date-format date))
           (ext ".live")
           (kws (if keywords (concat "_" (mapconcat #'downcase keywords "_")) ""))
           (sig (if (string-empty-p signature) "" (concat "==" signature)))
           (slug (replace-regexp-in-string "[^[:alnum:][:digit:]]" "-" 
                                           (downcase title)))
           (filename (concat id "--" slug kws sig ext))
           (path (expand-file-name filename subdir))
           (org-id (org-id-new))
           
           ;; Basic LaTeX frontmatter with ORG-ID
           (frontmatter
            (concat
             "#+TITLE:      " title "\n"
             "#+AUTHOR:     Shapeshifter\n"
             "#+DATE:       " date-formatted "\n"
             "#+IDENTIFIER: " id "\n"
             "#+FILETAGS:   " (if keywords (mapconcat #'identity keywords " ") "") "\n"
             (unless (string-empty-p signature)
               (concat "#+SIGNATURE:  " signature "\n"))
             "\n"
             "#+LATEX_CLASS: article\n"
             "#+LATEX_CLASS_OPTIONS: [11pt,a4paper]\n"
             "#+LATEX_COMPILER: lualatex\n"
             "#+LATEX_HEADER: \\usepackage{amsmath}\n"
             "#+LATEX_HEADER: \\usepackage{graphicx}\n"
             "#+LATEX_HEADER: \\usepackage{hyperref}\n"
             "#+LATEX_HEADER: \\usepackage{fontspec}\n"
             "#+OPTIONS: toc:nil num:t\n"
             "\n"
             "* " title "\n"
             ":PROPERTIES:\n"
             ":ID:       " org-id "\n"
             ":END:\n\n"
             "Write your manuscript here.\n\n"
             "** Section Example\n\n"
             "Use LaTeX inline: $E = mc^2$\n\n"
             "Display equations:\n"
             "\\begin{equation}\n"
             "\\int_{a}^{b} f(x) dx\n"
             "\\end{equation}\n")))
      
      ;; Write the file
      (write-region frontmatter nil path)
      
      ;; Ask about bidirectional linking
      (when (and shapeshift/source-buffer-for-linking
                 (y-or-n-p "Create bidirectional link with source note? "))
        (shapeshift/insert-bidirectional-link 
         (buffer-file-name shapeshift/source-buffer-for-linking)
         path))
      
      ;; Export to all formats immediately
      (shapeshift/export-to-all-formats path subdir)
      
      path)))

  ;;────────── Multi-Format Export System (EXPANDED) ──────────
  (defun shapeshift/get-relative-silo-path (file-path)
    "Get relative silo path from silos directory."
    (file-relative-name 
     (file-name-directory file-path) 
     shapeshift/denote-silos-dir))

  (defun shapeshift/ensure-formats-mirror-dir (relative-silo format-ext)
    "Create mirror directory structure in formats/FORMAT_EXT/silo/subsilo."
    (let* ((format-base (expand-file-name format-ext shapeshift/denote-formats-dir))
           (mirror-dir (expand-file-name relative-silo format-base)))
      (unless (file-directory-p mirror-dir)
        (make-directory mirror-dir t))
      mirror-dir))

  (defun shapeshift/export-to-all-formats (live-file original-subdir)
    "Export .live file to all formats with mirrored directory structure."
    (let* ((relative-silo (shapeshift/get-relative-silo-path live-file))
           (base-name (file-name-sans-extension (file-name-nondirectory live-file)))
           (formats '(("txt" . org-ascii-export-to-ascii)
                      ("tex" . org-latex-export-to-latex)
                      ("html" . org-html-export-to-html)
                      ("md" . org-md-export-to-markdown)
                      ("pdf" . org-latex-export-to-pdf)
                      ("docx" . org-odt-export-to-odt)
                      ("beamer" . org-beamer-export-to-pdf))))
      
      (with-current-buffer (find-file-noselect live-file)
        (dolist (format-pair formats)
          (let* ((ext (car format-pair))
                 (export-fn (cdr format-pair))
                 (mirror-dir (shapeshift/ensure-formats-mirror-dir relative-silo ext))
                 (output-file (expand-file-name 
                               (concat base-name "." ext) 
                               mirror-dir)))
            (condition-case err
                (progn
                  (funcall export-fn)
                  ;; Move exported file to formats directory
                  (let ((temp-export (concat (file-name-sans-extension live-file) "." ext)))
                    (when (file-exists-p temp-export)
                      (rename-file temp-export output-file t)
                      (message "Exported: %s → formats/%s/" base-name ext))))
              (error 
               (message "Export to %s failed: %s" ext (error-message-string err))))))
        
        ;; Keep .org copy in formats/org as well
        (let* ((org-mirror-dir (shapeshift/ensure-formats-mirror-dir relative-silo "org"))
               (org-copy (expand-file-name (concat base-name ".org") org-mirror-dir)))
          (copy-file live-file org-copy t))
        
        (message "✓ Exported to all formats in: formats/"))))

  ;;────────── Cleanup Function: Remove Non-.live Files from Silos ──────────
  (defun shapeshift/cleanup-silos ()
    "Remove all non-.live files from silos directory (exports, temps, etc)."
    (interactive)
    (let ((files-to-clean 
           (directory-files-recursively 
            shapeshift/denote-silos-dir
            "\\(\\.org\\|\\.tex\\|\\.pdf\\|\\.html\\|\\.txt\\|\\.md\\|\\.odt\\)$")))
      (dolist (file files-to-clean)
        (when (file-exists-p file)
          (delete-file file)
          (message "Cleaned: %s" file)))
      (message "✓ Silos cleaned: only .live files remain")))

;;────────────────────────────────────────────────────────────
;; Auto-Export on Save Hook + Cleanup
;;────────────────────────────────────────────────────────────
(defun shapeshift/auto-export-on-save ()
  "Auto-export current .live file and clean up silos directory."
  (when (and (buffer-file-name)
             (string-suffix-p ".live" (buffer-file-name))
             (string-prefix-p (expand-file-name shapeshift/denote-silos-dir) 
                              (expand-file-name (buffer-file-name))))
    (let ((live-file (buffer-file-name))
          (subdir (file-name-directory (buffer-file-name))))
      (shapeshift/export-to-all-formats live-file subdir)
      ;; Clean up any leftover exports in silos
      (shapeshift/cleanup-silos))))

(add-hook 'after-save-hook #'shapeshift/auto-export-on-save)

;;────────────────────────────────────────────────────────────
;; .live File Mode Detection
;;────────────────────────────────────────────────────────────
(add-to-list 'auto-mode-alist '("\\.live\\'" . org-mode))

;;────────────────────────────────────────────────────────────
;; Org-Capture Templates with Source Tracking
;;────────────────────────────────────────────────────────────
(with-eval-after-load 'denote
  (with-eval-after-load 'org-capture
    (setq org-capture-templates
          '(("n" "New Denote Note (.live format)" plain
             (file shapeshift/denote-capture-create-file)
             ""
             :empty-lines 1
             :jump-to-captured t
             :prepare-finalize (setq shapeshift/source-buffer-for-linking 
                                     (current-buffer)))))))

;;────────────────────────────────────────────────────────────
;; Essential Keybindings (Minimal, Most Automatic)
;;────────────────────────────────────────────────────────────
(with-eval-after-load 'denote
  (with-eval-after-load 'evil
    ;; Core creation
    (define-key evil-normal-state-map (kbd "SPC n n")
      (lambda () (interactive) (org-capture nil "n")))
    
    ;; Navigation
    (define-key evil-normal-state-map (kbd "SPC n d")
      (lambda () (interactive) (dired shapeshift/denote-silos-dir)))
    (define-key evil-normal-state-map (kbd "SPC n e")
      (lambda () (interactive) (dired shapeshift/denote-formats-dir)))
    
    ;; Linking
    (define-key evil-normal-state-map (kbd "SPC n l") #'denote-link)
    (define-key evil-normal-state-map (kbd "SPC n b") #'denote-backlinks)))

;; ORG-ROAM keybindings (Minimal)
(with-eval-after-load 'org-roam
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "SPC r f") #'org-roam-node-find)
    (define-key evil-normal-state-map (kbd "SPC r i") #'org-roam-node-insert)
    (define-key evil-normal-state-map (kbd "SPC r b") #'org-roam-buffer-toggle)))

;;────────────────────────────────────────────────────────────
;; LaTeX Manuscript Mode (FIXED)
;;────────────────────────────────────────────────────────────
(leaf cdlatex
  :straight (cdlatex :type git :host github :repo "cdominik/cdlatex"))

(leaf org-fragtog
  :straight (org-fragtog :type git :host github :repo "io12/org-fragtog"))

(leaf auctex
  :straight (auctex :type git :host github :repo "emacs-straight/auctex"))

(leaf pdf-tools
  :straight (pdf-tools :type git :host github :repo "vedang/pdf-tools")
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-tools-install)
  :config
  (setq pdf-view-display-size 'fit-page))

(setq-default TeX-master nil)

(defvar shapeshift/org-latex-export-timer nil)

(defun shapeshift/show-pdf-in-split (pdf)
  "Open PDF preview buffer in a split window without marking it visited."
  (when (and pdf (file-exists-p pdf))
    (delete-other-windows)
    (split-window-right)
    (other-window 1)
    (let* ((buffer (find-file-noselect pdf)))
      (with-current-buffer buffer
        (pdf-view-mode)
        (auto-revert-mode 1)
        (setq buffer-read-only t)
        (setq revert-without-query '(".*\\.pdf")))
      (switch-to-buffer buffer))
    (other-window -1)))

(defun shapeshift/get-pdf-path-in-formats (org-file)
  "Get the PDF path in formats/pdf/ directory for ORG-FILE."
  (when org-file
    (let* ((relative-path (shapeshift/get-relative-silo-path org-file))
           (base-name (file-name-sans-extension 
                       (file-name-nondirectory org-file)))
           (pdf-dir (expand-file-name 
                     relative-path
                     (expand-file-name "pdf" shapeshift/denote-formats-dir))))
      (expand-file-name (concat base-name ".pdf") pdf-dir))))

(defun shapeshift/org-export-and-preview-split ()
  "Export Org to PDF and preview in split window with idle delay."
  (interactive)
  (when shapeshift/org-latex-export-timer
    (cancel-timer shapeshift/org-latex-export-timer))
  (setq shapeshift/org-latex-export-timer
        (run-with-idle-timer
         0.4 nil
         (lambda ()
           (when (buffer-file-name)
             (let* ((org-file (buffer-file-name))
                    (pdf-in-silos (concat (file-name-sans-extension org-file) ".pdf"))
                    (pdf-in-formats (shapeshift/get-pdf-path-in-formats org-file)))
               (org-latex-export-to-pdf)
               ;; Use PDF from formats directory for preview
               (when (file-exists-p pdf-in-formats)
                 (shapeshift/show-pdf-in-split pdf-in-formats)
                 (message "PDF updated ✓"))
               ;; Clean up silos
               (when (file-exists-p pdf-in-silos)
                 (delete-file pdf-in-silos))))))))

(defun shapeshift/org-latex-manuscript-mode ()
  "Enable Live-Shaping manuscript preview workflow."
  (interactive)
  (visual-line-mode 1)
  (org-cdlatex-mode 1)
  (org-fragtog-mode 1)
  (setq-local TeX-command-extra-options "-shell-escape")
  (shapeshift/org-export-and-preview-split)
  (add-hook 'after-save-hook #'shapeshift/org-export-and-preview-split nil t)
  (message "Manuscript mode enabled: Split live preview"))

(defun shapeshift/maybe-enable-manuscript-mode ()
  "Enable manuscript mode only for .live files with LaTeX."
  (when (and (buffer-file-name)
             (string-suffix-p ".live" (buffer-file-name))
             (save-excursion
               (goto-char (point-min))
               (re-search-forward "^#\\+LATEX_CLASS:" nil t)))
    (shapeshift/org-latex-manuscript-mode)))

(add-hook 'org-mode-hook #'shapeshift/maybe-enable-manuscript-mode)
