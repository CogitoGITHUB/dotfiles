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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval modify-syntax-entry 43 "'") (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (eval progn (require 'lisp-mode)
	   (defun emacs27-lisp-fill-paragraph (&optional justify)
	     (interactive "P")
	     (or (fill-comment-paragraph justify)
		 (let
		     ((paragraph-start
		       (concat paragraph-start
			       "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
		      (paragraph-separate
		       (concat paragraph-separate
			       "\\|\\s-*\".*[,\\.]$"))
		      (fill-column
		       (if
			   (and
			    (integerp emacs-lisp-docstring-fill-column)
			    (derived-mode-p 'emacs-lisp-mode))
			   emacs-lisp-docstring-fill-column
			 fill-column)))
		   (fill-paragraph justify))
		 t))
	   (setq-local fill-paragraph-function
		       #'emacs27-lisp-fill-paragraph))
     (geiser-insert-actual-lambda) (geiser-repl-per-project-p . t)
     (eval with-eval-after-load 'yasnippet
	   (let
	       ((guix-yasnippets
		 (expand-file-name "etc/snippets/yas"
				   (locate-dominating-file
				    default-directory ".dir-locals.el"))))
	     (unless (member guix-yasnippets yas-snippet-dirs)
	       (add-to-list 'yas-snippet-dirs guix-yasnippets)
	       (yas-reload-all))))
     (eval with-eval-after-load 'tempel
	   (if (stringp tempel-path)
	       (setq tempel-path (list tempel-path)))
	   (let
	       ((guix-tempel-snippets
		 (concat
		  (expand-file-name "etc/snippets/tempel"
				    (locate-dominating-file
				     default-directory
				     ".dir-locals.el"))
		  "/*.eld")))
	     (unless (member guix-tempel-snippets tempel-path)
	       (add-to-list 'tempel-path guix-tempel-snippets))))
     (eval with-eval-after-load 'git-commit
	   (add-to-list 'git-commit-trailers "Change-Id"))
     (eval setq-local guix-directory
	   (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
