
;;; early-init.el --- Shapeless early startup -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      gc-cons-threshold most-positive-fixnum)



;; ---------------------------------------------------------
;;  Load Live-Shaping modules (definitions) + vendor sources
;; ---------------------------------------------------------

(let* ((ls-dir (expand-file-name "Live-Shaping" user-emacs-directory))
       (defs-dir (expand-file-name "definitions" ls-dir))
       (srcs-dir (expand-file-name "sources" ls-dir)))

  ;; 1. Add vendor repos to load-path (do NOT load their files)
  (when (file-directory-p srcs-dir)
    (dolist (dir (directory-files-recursively srcs-dir "" t))
      (when (file-directory-p dir)
        (add-to-list 'load-path dir))))

  ;; 2. Load YOUR modules from definitions/
  (when (file-directory-p defs-dir)
    (dolist (file (directory-files-recursively defs-dir "\\.el$"))
      (load (file-name-sans-extension file) nil 'nomessage))))
