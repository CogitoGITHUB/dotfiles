(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

;; Cursor moves through wrapped segments naturally
(setq line-move-visual t)

;; Enable visual wrapping globally
(global-visual-line-mode 1)

;; Maintain clean, centered "manuscript-like" text columns
(use-package visual-fill-column
  :straight (visual-fill-column
             :type git
             :host github
             :repo "joostkremers/visual-fill-column")
  :hook (visual-line-mode . visual-fill-column-mode)
  :init
  (setq visual-fill-column-width 90
        visual-fill-column-center-text t))

(defun live-shaping/auto-tangle-and-reload ()
  "When Emacs.org is saved, tangle it and reload init.el."
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.config/emacs/Emacs.org"))
    (message "Live-Shaping: Tangling & Reloading...")
    (org-babel-tangle)
    (load-file "~/.config/emacs/init.el")
    (message "Live-Shaping: Reload complete.")))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)

(use-package evil
  :straight (evil :type git :host github :repo "emacs-evil/evil")
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1)

  ;; Make Evil obey screen-line movement
  (setq evil-respect-visual-line-mode t)

  ;; Visual-line-aware navigation for HTNS
  (define-key evil-normal-state-map (kbd "t") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "n") 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)
  (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)

  (define-key evil-visual-state-map (kbd "t") 'evil-next-visual-line)
  (define-key evil-visual-state-map (kbd "n") 'evil-previous-visual-line)
  (define-key evil-visual-state-map (kbd "s") 'evil-forward-char)
  (define-key evil-visual-state-map (kbd "h") 'evil-backward-char))

(use-package evil-collection
  :after evil
  :straight (evil-collection :type git :host github :repo "emacs-evil/evil-collection")
  :config (evil-collection-init))

(defun tmp-f-timestamp (s backend info)
  (replace-regexp-in-string "&[lg]t;\\|[][]" "" s))
(defun tmp-f-strike-through (s backend info) "")

(use-package denote
   :straight (denote :type git :host github :repo "protesilaos/denote")
   :init
   (setq denote-directory (expand-file-name "~/Shapeless-Links")
         denote-sort-keywords t
         denote-file-type 'org
         denote-known-keywords '("emacs" "manual" "lisp" "shaping" "core"))
(denote-rename-buffer-mode 1)
   :config
   )
