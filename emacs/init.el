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
;; Leaf system
;;──────────────────────────────────────────────────────────
(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(require 'leaf)
(require 'leaf-keywords)
(leaf-keywords-init)
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
           (fringe-mode . 0)
           (mode-line-format . nil)))  ;; hide mode line

(leaf literate-config-system
  :straight (literate-config-system
             :type git
             :host github
             :repo "CogitoGITHUB/literate-config-system"
             :files ("*.el"))
  :init
  ;; nothing loads yet
  :config
  (literate-config-initialize))
