;;; literate-config-system.el --- Guix-native Literate Config Loader -*- lexical-binding: t -*-
;; Author: Shape
;; Version: 5.0.0
;; Package-Requires: ((emacs "29.1") (org "9.6") (leaf "0"))
;;; Code:

(require 'org)
(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § CONFIGURATION
;; ════════════════════════════════════════════════════════════════════

(defgroup literate-config nil
  "Guix-native literate configuration loader."
  :group 'org
  :prefix "lc-")

(defcustom lc-org-directory
  (expand-file-name "Literative Configurations/" user-emacs-directory)
  "Root directory for literate config org files."
  :type 'directory
  :group 'literate-config)

(defcustom lc-use-leaf t
  "Use leaf for package configuration wrapping."
  :type 'boolean
  :group 'literate-config)

(defcustom lc-silent t
  "Suppress all messages except success and errors."
  :type 'boolean
  :group 'literate-config)

;; ════════════════════════════════════════════════════════════════════
;; § STATE
;; ════════════════════════════════════════════════════════════════════

(defvar lc--load-errors nil
  "Alist of (file . error-message) for failed loads.")

(defvar lc--loaded-packages nil
  "List of successfully loaded package names.")

(defvar lc--load-order nil
  "Ordered list of files as they were processed.")

;; ════════════════════════════════════════════════════════════════════
;; § SILENT MESSAGING
;; ════════════════════════════════════════════════════════════════════

(defmacro lc--silent (&rest body)
  "Execute BODY suppressing all messages unless `lc-silent' is nil."
  `(if lc-silent
       (let ((inhibit-message t)
             (message-log-max nil))
         ,@body)
     (progn ,@body)))

(defun lc--log (level fmt &rest args)
  "Internal logger. LEVEL is 'ok or 'error only.
All other levels are suppressed when `lc-silent' is t."
  (pcase level
    ('ok    (message "✓ %s" (apply #'format fmt args)))
    ('error (message "✗ ERROR: %s" (apply #'format fmt args)))))

;; ════════════════════════════════════════════════════════════════════
;; § GUIX LOAD-PATH INTEGRATION
;; ════════════════════════════════════════════════════════════════════

(defun lc--ensure-guix-load-path ()
  "Ensure Guix Emacs profile is on load-path.
Guix sets EMACSLOADPATH; this makes sure Emacs sees it."
  (let ((guix-load-path (getenv "EMACSLOADPATH")))
    (when guix-load-path
      (lc--silent
       (dolist (path (split-string guix-load-path ":"))
         (when (and (not (string-empty-p path))
                    (file-directory-p path)
                    (not (member path load-path)))
           (add-to-list 'load-path path)))))))

;; ════════════════════════════════════════════════════════════════════
;; § PROPERTY EXTRACTION
;; ════════════════════════════════════════════════════════════════════

(defun lc--extract-props ()
  "Extract package properties from org entry at point.
Returns a plist or nil if no :PACKAGE: property found."
  (let* ((props (org-entry-properties nil 'standard))
         (package (cdr (assoc "PACKAGE" props))))
    (when package
      (list :package  package
            :after    (cdr (assoc "AFTER"    props))
            :depends  (cdr (assoc "DEPENDS"  props))
            :category (cdr (assoc "CATEGORY" props))
            :built-in (cdr (assoc "BUILT-IN" props))
            :defer    (cdr (assoc "DEFER"    props))))))

;; ════════════════════════════════════════════════════════════════════
;; § CODE BLOCK EXTRACTION
;; ════════════════════════════════════════════════════════════════════

(defun lc--blocks-in-region (beg end tangle-type)
  "Collect src-block contents in region BEG..END matching TANGLE-TYPE.
TANGLE-TYPE is the symbol 'init or 'config."
  (save-excursion
    (let ((result '()))
      (org-element-map
          (org-element-parse-buffer) 'src-block
        (lambda (src)
          (let* ((src-beg  (org-element-property :begin src))
                 (src-end  (org-element-property :end   src))
                 (headline (save-excursion
                             (goto-char src-beg)
                             (org-get-heading t t t t)))
                 (tangle   (save-excursion
                             (goto-char src-beg)
                             (cdr (assoc "TANGLE"
                                        (org-entry-properties nil 'standard)))))
                 (lang     (org-element-property :language src)))
            (when (and (>= src-beg beg)
                       (<= src-end end)
                       (string= lang "emacs-lisp")
                       (pcase tangle-type
                         ('init   (string= tangle "init"))
                         ('config (or (string= tangle "config")
                                     (null tangle)))))
              (push (org-element-property :value src) result)))))
      (mapconcat #'identity (nreverse result) "\n\n"))))

;; ════════════════════════════════════════════════════════════════════
;; § LEAF GENERATION
;; ════════════════════════════════════════════════════════════════════

(defun lc--build-leaf (props init-code config-code)
  "Build a leaf form from PROPS, INIT-CODE, and CONFIG-CODE.
Returns an s-expression ready for eval."
  (let* ((package     (intern (plist-get props :package)))
         (after-raw   (plist-get props :after))
         (defer       (plist-get props :defer))
         (after-syms  (when after-raw
                        (mapcar #'intern (split-string after-raw)))))
    `(leaf ,package
       :require t                              ;; ← replaces :straight, just require
       ,@(when after-syms  `(:after ,after-syms))
       ,@(when defer       '(:defer t))
       ,@(when (and init-code (not (string-empty-p init-code)))
           (condition-case err
               `(:init ,(read (concat "(progn\n" init-code "\n)")))
             (error
              (lc--log 'error "Init parse failed for %s: %s"
                       package (error-message-string err))
              nil)))
       ,@(when (and config-code (not (string-empty-p config-code)))
           (condition-case err
               `(:config ,(read (concat "(progn\n" config-code "\n)")))
             (error
              (lc--log 'error "Config parse failed for %s: %s"
                       package (error-message-string err))
              nil))))))

;; ════════════════════════════════════════════════════════════════════
;; § REQUIRE FALLBACK (no leaf)
;; ════════════════════════════════════════════════════════════════════

(defun lc--load-no-leaf (props init-code config-code)
  "Load package from PROPS without leaf.
Runs INIT-CODE, requires package, then runs CONFIG-CODE."
  (let ((package (intern (plist-get props :package))))
    (lc--silent
     (when (and init-code (not (string-empty-p init-code)))
       (eval (read (concat "(progn\n" init-code "\n)")) t))
     (require package nil 'noerror)
     (when (and config-code (not (string-empty-p config-code)))
       (eval (read (concat "(progn\n" config-code "\n)")) t)))))

;; ════════════════════════════════════════════════════════════════════
;; § FILE LOADER
;; ════════════════════════════════════════════════════════════════════

(defun lc--load-file (file)
  "Process a single org FILE, loading all package headlines within it."
  (condition-case err
      (with-temp-buffer
        (insert-file-contents file)
        (org-mode)
        (goto-char (point-min))

        (while (re-search-forward "^\\* " nil t)
          (save-excursion
            (let* ((props (lc--extract-props))
                   (package (plist-get props :package)))

              (when (and props package)
                (let* ((h-start (point))
                       (h-end   (save-excursion
                                  (org-end-of-subtree t t)
                                  (point)))
                       (init-code   (lc--blocks-in-region h-start h-end 'init))
                       (config-code (lc--blocks-in-region h-start h-end 'config)))

                  (condition-case pkg-err
                      (progn
                        (if lc-use-leaf
                            (lc--silent
                             (eval (lc--build-leaf props init-code config-code) t))
                          (lc--load-no-leaf props init-code config-code))
                        (push package lc--loaded-packages))
                    (error
                     (let ((msg (format "%s in %s: %s"
                                        package
                                        (file-name-nondirectory file)
                                        (error-message-string pkg-err))))
                       (push (cons package msg) lc--load-errors)
                       (lc--log 'error "%s" msg))))))))))
    (error
     (let ((msg (format "File load failed %s: %s"
                        (file-name-nondirectory file)
                        (error-message-string err))))
       (push (cons file msg) lc--load-errors)
       (lc--log 'error "%s" msg)))))

;; ════════════════════════════════════════════════════════════════════
;; § DIRECTORY SCANNER
;; ════════════════════════════════════════════════════════════════════

(defun lc--collect-files (directory)
  "Recursively collect all .org files under DIRECTORY, sorted."
  (when (file-directory-p directory)
    (sort
     (directory-files-recursively directory "\\.org$")
     #'string<)))

;; ════════════════════════════════════════════════════════════════════
;; § MAIN ENTRY POINT
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defun literate-config-load ()
  "Load all literate org config files from `lc-org-directory'.
Prints one success line or error details — nothing in between."
  (interactive)
  (setq lc--load-errors    nil
        lc--loaded-packages nil
        lc--load-order      nil)

  (lc--ensure-guix-load-path)

  (let ((files (lc--collect-files lc-org-directory)))
    (if (null files)
        (lc--log 'error "No .org files found in %s" lc-org-directory)
      (dolist (file files)
        (push file lc--load-order)
        (lc--load-file file))

      (if lc--load-errors
          (progn
            (lc--log 'error "%d package(s) failed — see *Messages* for details"
                     (length lc--load-errors))
            (dolist (e lc--load-errors)
              (message "  ✗ %s" (cdr e))))
        (lc--log 'ok "%d packages loaded from %d files"
                 (length lc--loaded-packages)
                 (length files))))))

;;;###autoload
(defun literate-config-status ()
  "Show a summary buffer of loaded packages and any errors."
  (interactive)
  (with-current-buffer (get-buffer-create "*literate-config-status*")
    (erase-buffer)
    (insert (format "Literate Config Status — %s\n\n"
                    (format-time-string "%Y-%m-%d %H:%M:%S")))
    (insert (format "✓ Loaded: %d packages\n" (length lc--loaded-packages)))
    (insert (format "✗ Errors: %d\n\n"        (length lc--load-errors)))
    (when lc--loaded-packages
      (insert "Loaded:\n")
      (dolist (p (reverse lc--loaded-packages))
        (insert (format "  • %s\n" p))))
    (when lc--load-errors
      (insert "\nErrors:\n")
      (dolist (e lc--load-errors)
        (insert (format "  ✗ %s\n" (cdr e)))))
    (display-buffer (current-buffer))))

(provide 'literate-config-system)
;;; literate-config-system.el ends here
