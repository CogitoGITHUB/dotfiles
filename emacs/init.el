;;; init.el --- LiterativeOS Emacs Entry Point -*- lexical-binding: t -*-

;; Add guix home profile packages to load-path
(let ((home-profile (concat (getenv "HOME") "/.guix-home/profile")))
  (when (file-directory-p home-profile)
    (let ((site-lisp (concat home-profile "/share/emacs/site-lisp")))
      (when (file-directory-p site-lisp)
        (add-to-list 'load-path site-lisp)
        (dolist (dir (directory-files site-lisp t "^[^.]"))
          (when (file-directory-p dir)
            (add-to-list 'load-path dir)))))))

;; Load Org from Guix before anything else
(condition-case nil
    (require 'org)
  (file-missing nil))

;; Bootstrap leaf
(require 'leaf)
(condition-case nil
    (progn
      (require 'leaf-keywords)
      (leaf-keywords-init))
  (file-missing nil))

;; Add local lisp directories to load-path for submodules
(let ((lisp-dir (expand-file-name "lisp/" user-emacs-directory)))
  (add-to-list 'load-path lisp-dir)
  (dolist (subdir (directory-files lisp-dir t "^[^.]" t))
    (when (file-directory-p subdir)
      (add-to-list 'load-path subdir))))

;; Load literate-config-system which handles EVERYTHING
(condition-case err
    (progn
      (require 'literate-config-system)
      (literate-config-load))
  (error
   (message "Error loading literate-config-system: %S" err)))

;; Ensure server is started when daemon mode is requested
(when (daemonp)
  (require 'server)
  (unless (server-running-p)
    (server-start)))

;;; init.el ends here
