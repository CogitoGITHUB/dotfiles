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

;;──────────────────────────────────────────────────────────
;; Org-Based Configuration System
;;──────────────────────────────────────────────────────────

(add-to-list 'load-path (expand-file-name "lisp/literate-config-emacs" user-emacs-directory))
(require 'literate-config-emacs)
(literate-config-emacs-enable)

(defvar my/agent-shell-opencode-config
  '(:provider "opencode"
    :model "gpt-4"
    :api-key (lambda () (getenv "OPENAI_API_KEY"))))

(leaf agent-shell
   :straight (agent-shell
              :type git
              :host github
              :repo "xenodium/agent-shell")
   :after (acp shell-maker)
   :commands (agent-shell)
   :init
   ;; Inject BEFORE agent-shell loads
   (setq agent-shell-agent-configs (list my/agent-shell-opencode-config)
         agent-shell-preferred-agent-config my/agent-shell-opencode-config
         agent-shell-start-function 'agent-shell-opencode-start-agent)
   :config
   (defalias 'ai 'agent-shell-opencode-start-agent))

(defun live-shaping/auto-tangle-and-reload ()
  "Auto-tangle and reload when this Org file tangles to init.el."
  (when (and buffer-file-name
             (save-excursion
               (goto-char (point-min))
               (re-search-forward ":tangle[ \t]+init.el" nil t)))
    (message "Tangling…")
    (condition-case err
        (progn
          (org-babel-tangle)
          (load-file (expand-file-name "init.el" user-emacs-directory))
          (message "Reload complete ✓"))
      (error
       (display-warning
        'live-shaping (format "%s" (error-message-string err)) :error)))))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)
