;;; literate-config-emacs.el --- Live configuration management through Org files -*- lexical-binding: t -*-
;; Copyright (C) 2025
;; Author: CogitoGITHUB
;; Version: 2.0.2
;; Package-Requires: ((emacs "26.1") (org "9.0"))
;; Keywords: convenience, org, config
;;; Commentary:
;; Loads all .org files from "Literative Configurations" directory
;;; Code:
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'ob-core)

(defgroup literate-config-emacs nil
  "Live configuration management through Org files."
  :group 'convenience
  :prefix "literate-config-emacs-")

(defcustom literate-config-emacs-output-directory 
  (expand-file-name "shaped-outputs" user-emacs-directory)
  "Directory where compiled Elisp files are stored."
  :type 'string
  :group 'literate-config-emacs)

(defcustom literate-config-emacs-org-directory 
  (expand-file-name "Literative Configurations" user-emacs-directory)
  "Directory where source Org files are stored."
  :type 'string
  :group 'literate-config-emacs)

(defcustom literate-config-emacs-cache-compilation t
  "Cache compilation results."
  :type 'boolean
  :group 'literate-config-emacs)

(defvar literate-config-emacs--booting nil)
(defvar literate-config-emacs--boot-errors '())

(defun literate-config-emacs--file-in-directory-p (file dir)
  "Check if FILE is in DIR or subdirectory."
  (let ((file (expand-file-name file))
        (dir (file-name-as-directory (expand-file-name dir))))
    (string-prefix-p dir file)))

(defun literate-config-emacs-file-hash (file)
  "Calculate hash of FILE."
  (when (and file (file-exists-p file))
    (condition-case err
        (secure-hash 'md5 (with-temp-buffer
                            (insert-file-contents file)
                            (buffer-string)))
      (error nil))))

(defun literate-config-emacs-cache-file-name (file)
  "Return cache file name for FILE."
  (let ((hash (literate-config-emacs-file-hash file)))
    (when hash
      (expand-file-name
       (concat (file-name-base file) "-" hash ".cache")
       (expand-file-name ".cache" literate-config-emacs-output-directory)))))

(defun literate-config-emacs-is-cached (file)
  "Check if FILE has valid cache."
  (let ((cache-file (literate-config-emacs-cache-file-name file))
        (source-hash (literate-config-emacs-file-hash file)))
    (and cache-file source-hash
         (file-exists-p cache-file)
         (condition-case nil
             (with-temp-buffer
               (insert-file-contents cache-file)
               (string= (buffer-string) source-hash))
           (error nil)))))

(defun literate-config-emacs-write-cache (file)
  "Write cache for FILE."
  (let ((cache-file (literate-config-emacs-cache-file-name file))
        (file-hash (literate-config-emacs-file-hash file)))
    (when (and cache-file file-hash)
      (condition-case err
          (progn
            (make-directory (file-name-directory cache-file) t)
            (with-temp-file cache-file
              (insert file-hash)))
        (error nil)))))

(defun literate-config-emacs-output-file-name (file)
  "Return output elisp file path for org FILE."
  (let* ((expanded-file (expand-file-name file))
         (expanded-org-dir (file-name-as-directory 
                            (expand-file-name literate-config-emacs-org-directory))))
    (if (string-prefix-p expanded-org-dir expanded-file)
        (let ((relative-path (substring expanded-file (length expanded-org-dir))))
          (expand-file-name
           (concat (file-name-sans-extension relative-path) ".el")
           literate-config-emacs-output-directory))
      (error "File not in literate-config-emacs-org-directory: %s" file))))

(defun literate-config-emacs-extract-packages (file)
  "Extract (package . spec) alist from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((packages '()))
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (headline)
          (let ((package-raw (org-element-property :PACKAGE headline))
                (straight-raw (org-element-property :STRAIGHT headline)))
            (when (and package-raw straight-raw)
              (let ((package (string-trim package-raw))
                    (straight (string-trim straight-raw)))
                (let ((spec (if (string= straight "t")
                                (intern package)
                              (read straight))))
                  (push (cons (intern package) spec) packages)))))))
      (nreverse packages))))

(defun literate-config-emacs-concatenate-source-blocks (file)
  "Extract all emacs-lisp source blocks from FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (let ((results '()))
      (org-babel-map-src-blocks nil
        (let ((body (org-element-property :value (org-element-context)))
              (language (org-element-property :language (org-element-context))))
          (when (string= language "emacs-lisp")
            (push body results))))
      (mapconcat 'identity (nreverse results) "\n"))))

(defun literate-config-emacs-compile-file (file &optional force)
  "Compile org FILE to elisp."
  (unless (file-exists-p file)
    (error "File does not exist: %s" file))
  
  (let ((output-file (literate-config-emacs-output-file-name file)))
    (make-directory (file-name-directory output-file) t)
    
    (if (and literate-config-emacs-cache-compilation 
             (not force)
             (literate-config-emacs-is-cached file)
             (file-exists-p output-file)
             (not (file-newer-than-file-p file output-file)))
        (progn
          (message "Literate-Config-Emacs: Using cached %s" file)
          output-file)
      
      (when (or force
                (not (file-exists-p output-file))
                (file-newer-than-file-p file output-file))
        (message "Literate-Config-Emacs: Compiling %s" file)
        (condition-case err
            (let* ((start-time (current-time))
                   (output (literate-config-emacs-concatenate-source-blocks file)))
              
              (with-temp-file output-file
                (insert ";;; -*- lexical-binding: t -*-\n\n")
                (insert output))
              
              (when literate-config-emacs-cache-compilation
                (literate-config-emacs-write-cache file))
              
              (let ((time (float-time (time-subtract (current-time) start-time))))
                (message "Literate-Config-Emacs: Compiled %s in %.3fs" file time))
              output-file)
          (error
           (message "Error compiling %s: %s" file (error-message-string err))
           (when literate-config-emacs--booting
             (push (cons file err) literate-config-emacs--boot-errors))
           nil))))))

(defun literate-config-emacs-get-files (extension directory)
  "Return all files matching EXTENSION in DIRECTORY recursively."
  (when (file-exists-p directory)
    (let ((files (directory-files-recursively directory extension)))
      (sort files 'string<))))

(defun literate-config-emacs-compile-directory ()
  "Compile all org files in literate-config-emacs-org-directory."
  (let* ((files (literate-config-emacs-get-files "^[^#]*\\.org$" 
                                              literate-config-emacs-org-directory))
         (compiled '())
         (start-time (current-time)))
    
    (dolist (file files)
      (when-let* ((output (literate-config-emacs-compile-file file)))
        (push output compiled)))
    
    (let ((time (float-time (time-subtract (current-time) start-time))))
      (message "Literate-Config-Emacs: Compiled %d files in %.3fs" (length files) time))
    
    (nreverse compiled)))

(defun literate-config-emacs-load-file (file)
  "Load elisp FILE."
  (let ((start-time (current-time)))
    (condition-case err
        (progn
          (load (expand-file-name file) nil t)
          (let ((time (float-time (time-subtract (current-time) start-time))))
            (message "Literate-Config-Emacs: Loaded %s (%.3fs)" file time)
            t))
      (error
       (message "Literate-Config-Emacs: Failed to load %s: %s" 
                file (error-message-string err))
       (when literate-config-emacs--booting
         (push (cons file err) literate-config-emacs--boot-errors))
       nil))))

(defun literate-config-emacs-load-directory ()
  "Load all compiled elisp files."
  (let* ((files (literate-config-emacs-get-files "^[^#]*\\.el$" 
                                              literate-config-emacs-output-directory))
         (start-time (current-time))
         (loaded 0)
         (failed 0))
    
    (dolist (file files)
      (if (literate-config-emacs-load-file file)
          (setq loaded (1+ loaded))
        (setq failed (1+ failed))))
    
    (let ((time (float-time (time-subtract (current-time) start-time))))
      (message "Literate-Config-Emacs: Loaded %d files (%d failed) in %.3fs" 
               loaded failed time))))

;;;###autoload
(defun literate-config-emacs-reload ()
  "Compile and load all org files."
  (interactive)
  (dolist (compiled-file (literate-config-emacs-compile-directory))
    (when compiled-file
      (literate-config-emacs-load-file compiled-file))))

;;;###autoload
(defun literate-config-emacs-reload-current-buffer ()
  "Compile and load current org file."
  (interactive)
  (unless (buffer-file-name (current-buffer))
    (user-error "Buffer not visiting a file"))
  (when-let* ((compiled (literate-config-emacs-compile-file 
                         (buffer-file-name (current-buffer)) t)))
    (literate-config-emacs-load-file compiled)))

;;;###autoload
(defun literate-config-emacs-boot ()
  "Compile and load all org files."
  (interactive)
  (let ((literate-config-emacs--booting t)
        (warning-minimum-level :error)
        (inhibit-message t))
    (setq literate-config-emacs--boot-errors '())
    ;; Install packages
    (let ((all-packages (make-hash-table :test 'equal)))
      (dolist (file (literate-config-emacs-get-files "^[^#]*\\.org$" 
                                                     literate-config-emacs-org-directory))
        (dolist (pkg-spec (literate-config-emacs-extract-packages file))
          (puthash pkg-spec t all-packages)))
      (maphash (lambda (pkg-spec _) 
                 (let ((package (car pkg-spec))
                       (spec (cdr pkg-spec)))
                   (straight-use-package spec)))
               all-packages))
    (literate-config-emacs-compile-directory)
    (literate-config-emacs-load-directory)
    (when literate-config-emacs--boot-errors
      (display-warning 
       'literate-config-emacs
       (format "Encountered %d errors during boot" 
               (length literate-config-emacs--boot-errors))
       :warning))))

;;;###autoload
(defun literate-config-emacs-enable ()
  "Enable literate-config-emacs system."
  (interactive)
  (unless (file-exists-p literate-config-emacs-org-directory)
    (make-directory literate-config-emacs-org-directory t))
  (unless (file-exists-p literate-config-emacs-output-directory)
    (make-directory literate-config-emacs-output-directory t))
  
  (let ((inhibit-message t))
    (literate-config-emacs-boot)))

;;;###autoload
(defun literate-config-emacs-clear-cache ()
  "Clear compilation cache."
  (interactive)
  (let ((cache-dir (expand-file-name ".cache" literate-config-emacs-output-directory)))
    (when (file-exists-p cache-dir)
      (delete-directory cache-dir t)
      (message "Literate-Config-Emacs: Cache cleared"))))

(provide 'literate-config-emacs)
;;; literate-config-emacs.el ends here
