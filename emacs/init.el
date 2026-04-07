;;; init.el --- LiterativeOS Emacs Entry Point -*- lexical-binding: t -*-

;; Add guix home profile packages to load-path
;; Guix packages are organized as directories, so we add both the site-lisp dir
;; and each subdirectory to ensure all packages are found
(let ((home-profile (concat (getenv "HOME") "/.guix-home/profile")))
  (when (file-directory-p home-profile)
    (let ((site-lisp (concat home-profile "/share/emacs/site-lisp")))
      (when (file-directory-p site-lisp)
        ;; Add main site-lisp directory
        (add-to-list 'load-path site-lisp)
        ;; Add all subdirectories (package versions like leaf-4.5.5, geiser-0.32, etc.)
        (dolist (dir (directory-files site-lisp t "^[^.]"))
          (when (file-directory-p dir)
            (add-to-list 'load-path dir)))))))

;; Bootstrap leaf (installed via Guix Home, now on load-path)
(require 'leaf)
(condition-case nil
    (progn
      (require 'leaf-keywords)
      (leaf-keywords-init))
  (file-missing nil))  ;; leaf-keywords is optional

;; Load the system
(add-to-list 'load-path
             (expand-file-name "lisp/" user-emacs-directory))
(require 'literate-config-system)
(literate-config-load)

;;; init.el ends here
