;;; init.el --- LiterativeOS Emacs Entry Point -*- lexical-binding: t -*-

;; Bootstrap leaf (installed via Guix, just require it)
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
