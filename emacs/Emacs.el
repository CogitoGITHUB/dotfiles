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
  (straight-use-package 'org)
  (require 'org)  ;; Force load immediately
  ;;──────────────────────────────────────────────────────────
  ;; Install leaf *before* leaf-keywords is used
  ;;──────────────────────────────────────────────────────────
  (straight-use-package 'leaf)
  (straight-use-package 'leaf-keywords)

  (require 'leaf)
  (require 'leaf-keywords)
  (leaf-keywords-init)

;;──────────────────────────────────────────────────────────
;; Primitive built-in configuration with leaf
;;──────────────────────────────────────────────────────────
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
           (fringe-mode . 0)))

(leaf center-lock
  :config
  (defvar shapeshift/center-lock-enabled t
    "Whether the cursor should remain vertically centered.")

  (defun shapeshift/recenter-maybe ()
    (when (and shapeshift/center-lock-enabled
               (not (eq this-command 'scroll-up-command))
               (not (eq this-command 'scroll-down-command))
               (not (minibufferp)))
      (recenter)))

  (define-minor-mode center-lock-mode
    "Keep the cursor vertically centered at all times."
    :global t
    (if center-lock-mode
        (add-hook 'post-command-hook #'shapeshift/recenter-maybe)
      (remove-hook 'post-command-hook #'shapeshift/recenter-maybe)))

  (center-lock-mode 1))

(leaf org-superstar
  :straight (org-superstar
             :type git
             :host github
             :repo "integral-dw/org-superstar-mode")
  :after org
  :hook (org-mode-hook . org-superstar-mode)
  :custom
  ((org-superstar-headline-bullets-list . '(?Ⅰ ?Ⅱ ?Ⅲ ?Ⅳ ?Ⅴ ?Ⅵ ?Ⅶ ?Ⅷ))
   (org-superstar-remove-leading-stars . t)
   (org-superstar-leading-fallback . ?\s))
  :config
  (custom-set-faces
   '(org-superstar-header-bullet ((t (:foreground "#000000" :weight bold :height 1.3))))
   '(org-superstar-item ((t (:foreground "#000000"))))
   '(org-superstar-leading ((t (:foreground "#000000"))))))

(leaf font-config
  :config
  ;; primary monospaced font
  (when (find-font (font-spec :name "DejaVu Sans Mono"))
    (set-face-attribute 'default nil
                        :family "DejaVu Sans Mono"
                        :height 100))

  ;; unicode fallback matrix
  (set-fontset-font t 'unicode "Symbola" nil 'prepend)
  (set-fontset-font t 'unicode "Noto Sans Symbols" nil 'prepend))

(leaf evil
  :straight (evil :type git :host github :repo "emacs-evil/evil" :branch "master" :fetch t)
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t)
  :config
  (evil-mode 1)

  (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)
  (define-key evil-normal-state-map (kbd "t") 'evil-next-line)
  (define-key evil-normal-state-map (kbd "n") 'evil-previous-line)
  (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)

  (define-key evil-motion-state-map (kbd "h") 'evil-backward-char)
  (define-key evil-motion-state-map (kbd "t") 'evil-next-line)
  (define-key evil-motion-state-map (kbd "n") 'evil-previous-line)
  (define-key evil-motion-state-map (kbd "s") 'evil-forward-char))



(leaf annalist
  :straight (annalist
             :type git
             :host github
             :repo "noctuid/annalist.el"
             :fetch t))

(leaf evil-collection
  :straight (evil-collection :type git :host github :repo "emacs-evil/evil-collection" :fetch t)
  :after evil
  :config
  (evil-collection-init))


(leaf evil-surround
  :straight (evil-surround :type git :host github :repo "timcharper/evil-surround" :fetch t)
  :config
  (global-evil-surround-mode 1))

;;──────────────────────────────────────────────────────────
;; Desktop save location setup
;;──────────────────────────────────────────────────────────
(setq desktop-dirname "~/.config/emacs/desktop/"
      desktop-path   '("~/.config/emacs/desktop/")
      desktop-base-file-name "emacs-desktop")

(make-directory desktop-dirname t) ;; ensure directory exists


;;──────────────────────────────────────────────────────────
;; Desktop Mode
;;──────────────────────────────────────────────────────────
(leaf desktop
  :require t
  :config
  ;; auto-save session when closing Emacs
  (add-hook 'kill-emacs-hook #'desktop-save-in-desktop-dir)

  ;; restore behavior tuning
  (setq desktop-restore-eager 8
        desktop-lazy-idle-delay 0.5
        desktop-load-locked-desktop t)

  (desktop-save-mode 1))

(leaf pulsar
  :straight (pulsar
             :type git
             :host github
             :repo "protesilaos/pulsar"
             :fetch t)
  :bind
  ("C-x l" . pulsar-pulse-line)
  ("C-x L" . pulsar-highlight-permanently-dwim)
  :config
  (setq pulsar-delay 0.055
        pulsar-iterations 5
        pulsar-face 'pulsar-red
        pulsar-region-face 'pulsar-red
        pulsar-highlight-face 'pulsar-red)

  (pulsar-global-mode 1))

(add-hook 'next-error-hook #'pulsar-pulse-line)

(add-hook 'minibuffer-setup-hook #'pulsar-pulse-line)

;; integration with the `consult' package:
(add-hook 'consult-after-jump-hook #'pulsar-recenter-top)
(add-hook 'consult-after-jump-hook #'pulsar-reveal-entry)

;; integration with the built-in `imenu':
(add-hook 'imenu-after-jump-hook #'pulsar-recenter-top)
(add-hook 'imenu-after-jump-hook #'pulsar-reveal-entry)

(leaf switch-window
  :straight (switch-window
             :type git
             :host github
             :repo "dimitri/switch-window"
             :fetch t)
  :bind
  ("C-x w" . switch-window)
  :config
  (setq switch-window-shortcut-style 'qwerty
        switch-window-timeout nil
        switch-window-threshold 2))

(leaf avy
  :straight (avy
             :type git
             :host github
             :repo "abo-abo/avy"
             :fetch t)
  :config
  ;; core behavior
  (setq avy-background nil  ; No background dimming
        avy-all-windows t
        avy-style 'at-full
        avy-timeout-seconds 0.4)
  (setq avy-keys (string-to-list "aoeuidhtns"))
  
  ;; clean grey theme
  (custom-set-faces
   '(avy-lead-face ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-0 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-1 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-2 ((t (:foreground "#000000" :background "#cccccc" :weight normal)))))
  
  ;; dispatch operations
  (setq avy-dispatch-alist
        '((?k . avy-kill-region)
          (?y . avy-copy-region)
          (?c . avy-kill-ring-save)))
  ;; bind teleport
  (define-key evil-normal-state-map (kbd "SPC") #'avy-goto-char-timer)
  (define-key evil-visual-state-map (kbd "SPC") #'avy-goto-char-timer)
  (define-key evil-motion-state-map (kbd "SPC") #'avy-goto-char-timer))

(leaf multiple-cursors
  :straight (multiple-cursors
             :type git
             :host github
             :repo "magnars/multiple-cursors.el"
             :fetch t)
  :config
  ;; evil + mc movement bindings
  (define-key evil-normal-state-map (kbd "g m n") #'mc/mark-next-like-this)
  (define-key evil-normal-state-map (kbd "g m p") #'mc/mark-previous-like-this)
  (define-key evil-normal-state-map (kbd "g m a") #'mc/mark-all-like-this)

  (define-key evil-visual-state-map (kbd "g m n") #'mc/mark-next-like-this)
  (define-key evil-visual-state-map (kbd "g m p") #'mc/mark-previous-like-this)

  ;; edit multiple lines
  (define-key evil-normal-state-map (kbd "g m l") #'mc/edit-lines)

  ;; escape mode
  (define-key evil-normal-state-map (kbd "<escape>") #'mc/keyboard-quit)
  (define-key evil-visual-state-map (kbd "<escape>") #'mc/keyboard-quit))

(leaf move-text
  :straight (move-text
             :type git
             :host github
             :repo "emacsfodder/move-text"
             :fetch t)
  :bind
  ("M-<up>"   . move-text-up)
  ("M-<down>" . move-text-down)
  :config
  ;; Evil integration
  (define-key evil-normal-state-map (kbd "M-<up>")   #'move-text-up)
  (define-key evil-normal-state-map (kbd "M-<down>") #'move-text-down)
  (define-key evil-visual-state-map (kbd "M-<up>")   #'move-text-up)
  (define-key evil-visual-state-map (kbd "M-<down>") #'move-text-down))

(leaf yasnippet
  :straight t
  :hook (after-init . yas-global-mode)
  :config
  ;; snippet roots
  (setq yas-snippet-dirs
        (list (expand-file-name "snippets" "~/.config/emacs/")
              (expand-file-name "snippets"
                                (file-name-directory (locate-library "yasnippet")))))

  ;; use AFTER load so warnings vanish
  (with-eval-after-load 'yasnippet
    (yas-reload-all))

  ;; expansion key
  (define-key yas-minor-mode-map (kbd "TAB") #'yas-expand))

(leaf auto-yasnippet
  :straight (auto-yasnippet
             :type git
             :host github
             :repo "abo-abo/auto-yasnippet")
  :bind
  ("C-c y w" . aya-create)
  ("C-c y e" . aya-expand)
  :config
  (setq aya-persist-snippets t
        aya-persist-directory (expand-file-name "auto-snippets" "~/.config/emacs/")))

(leaf evil-nerd-commenter
  :straight (evil-nerd-commenter
             :type git
             :host github
             :repo "redguardtoo/evil-nerd-commenter")
  :after evil
  :config
  (declare-function web-mode-comment-or-uncomment-region "web-mode")
  (setq evilnc-comment-text-object "c")
  (evilnc-default-hotkeys)
  (define-key evil-normal-state-map (kbd "gc") #'evilnc-comment-or-uncomment-lines)
  (define-key evil-visual-state-map (kbd "gc") #'evilnc-comment-or-uncomment-lines)
  (define-key evil-normal-state-map (kbd "gC") #'evilnc-copy-and-comment-lines))

(leaf dap-mode
  :straight (dap-mode
             :host github
             :repo "emacs-lsp/dap-mode")
  :after lsp-mode
  :config
  ;; core engine
  (dap-mode 1)
  (dap-ui-mode 1)

  ;; auto configuration
  (setq dap-auto-configure-mode t
        dap-auto-configure-features '(sessions locals controls tooltip))

  ;; muscle-memory debugging keys
  (define-key dap-mode-map (kbd "C-c d d") #'dap-debug)
  (define-key dap-mode-map (kbd "C-c d b") #'dap-breakpoint-toggle)
  (define-key dap-mode-map (kbd "C-c d n") #'dap-continue)
  (define-key dap-mode-map (kbd "C-c d s") #'dap-step-in)
  (define-key dap-mode-map (kbd "C-c d o") #'dap-step-out))

(leaf which-key
  :straight (which-key
             :host github
             :repo "justbur/emacs-which-key")
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.4
        which-key-max-description-length 40))

(leaf flycheck
  :straight (flycheck
             :host github
             :repo "flycheck/flycheck")
  :hook (after-init . global-flycheck-mode)
  :config
  (global-flycheck-mode 1)

  ;; Monochrome diagnosis
  (custom-set-faces
   '(flycheck-error   ((t (:underline (:style wave :color "#000000")))))
   '(flycheck-warning ((t (:underline (:style wave :color "#000000")))))
   '(flycheck-info    ((t (:underline (:style wave :color "#000000")))))))

(leaf projectile
  :straight (projectile
             :host github
             :repo "bbatsov/projectile")
  :init
  ;; Prefix before loading
  (setq projectile-keymap-prefix (kbd "C-c p"))
  :config
  (projectile-mode +1)

  ;; Search realms in your universe
  (setq projectile-project-search-path
        '("~/Projects"
          "~/Shapeless-Links"
          "~/AeonCore"))

  (setq projectile-enable-caching t
        projectile-completion-system 'default)

  ;; Use ripgrep for indexing if available
  (when (executable-find "rg")
    (setq projectile-generic-command
          "rg -0 --files --color=never --hidden --ignore-vcs"))

  ;; Bindings forged for motion
  (define-key projectile-mode-map (kbd "C-c p f") #'projectile-find-file)
  (define-key projectile-mode-map (kbd "C-c p p") #'projectile-switch-project)
  (define-key projectile-mode-map (kbd "C-c p b") #'projectile-switch-to-buffer)

  ;; monochrome modeline segment
  (custom-set-faces
   '(projectile-mode-line ((t (:foreground "#000000" :weight bold)))))

  )

(leaf compat
  :straight (compat
             :type git
             :host github
             :repo "emacs-straight/compat")
  :require compat)

(leaf org-timeblock
  :straight (org-timeblock
             :type git
             :host github
             :repo "ichernyshovvv/org-timeblock")
  :after org
  :commands (org-timeblock)
  :config
  (setq org-timeblock-files '("~/Shapeless-Links/"
                              "~/Projects/"))
  (setq org-timeblock-span 3))

(leaf magit-todos
  :straight (magit-todos
             :type git
             :host github
             :repo "alphapapa/magit-todos")
  :after magit
  :config
  (magit-todos-mode 1)

  ;; keyword spectrum
  (setq magit-todos-keywords '("TODO" "FIXME" "BUG" "NOTE"))

  ;; ignore noise
  (setq magit-todos-exclude-globs '("node_modules/*"
                                    "vendor/*"
                                    "*.min.js"))

  ;; carve a motion into magit-status
  (define-key magit-status-mode-map (kbd "j T")
    #'magit-todos-list))

(leaf modus-themes
  :straight (modus-themes
             :type git
             :host github
             :repo "protesilaos/modus-themes")
  :init
  (setq modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-org-blocks 'gray-background
        modus-themes-fringes 'intense)
  :config
  (load-theme 'modus-operandi :no-confirm)

  (defun shapeshift/monochrome-world ()
    ;; canvas
    (set-face-attribute 'default nil
                        :foreground "#000000"
                        :background "#ffffff")

    ;; org hierarchy — titanic black mono
    (set-face-attribute 'org-document-title nil :foreground "#000000" :weight 'bold :height 2.0 :inherit nil)
    (set-face-attribute 'org-level-1 nil :foreground "#000000" :weight 'bold :height 1.80 :inherit nil)
    (set-face-attribute 'org-level-2 nil :foreground "#000000" :weight 'bold :height 1.60 :inherit nil)
    (set-face-attribute 'org-level-3 nil :foreground "#000000" :weight 'bold :height 1.40 :inherit nil)

    ;; links stripped
    (set-face-attribute 'org-link nil :underline nil :inherit nil :foreground "#000000")

    ;; syntax, pure black
    (dolist (face '(font-lock-comment-face
                    font-lock-string-face
                    font-lock-keyword-face
                    font-lock-function-name-face
                    font-lock-variable-name-face
                    font-lock-type-face
                    font-lock-constant-face))
      (set-face-attribute face nil :foreground "#000000"))

    ;; Dired faces — only apply after Dired loads
    (with-eval-after-load 'dired
      (dolist (face '(dired-directory
                      dired-symlink
                      dired-mark
                      dired-marked
                      dired-flagged
                      dired-warning
                      dired-perm-write
                      dired-special))
        (set-face-attribute face nil :foreground "#000000" :weight 'bold :inherit nil))))

  ;; Apply immediately
  (shapeshift/monochrome-world)

  ;; persist after theme reload
  (advice-add 'load-theme :after
              (lambda (&rest _) (shapeshift/monochrome-world))))

(leaf visual-fill-column
  :straight (visual-fill-column
             :type git
             :host github
             :repo "joostkremers/visual-fill-column")
  :require visual-fill-column)

(leaf writeroom-mode
  :straight (writeroom-mode
             :type git
             :host github
             :repo "joostkremers/writeroom-mode")
  :global-minor-mode global-writeroom-mode
  :after visual-fill-column
  :config
  ;; No fullscreen or rewriting windows
  (setq writeroom-global-effects nil
        writeroom-maximize-window nil
        writeroom-mode-line nil
        writeroom-bottom-divider-width 0)

  ;; Evil-width precision bindings
  (with-eval-after-load 'writeroom-mode
    (define-key writeroom-mode-map (kbd "C-M-<") #'writeroom-decrease-width)
    (define-key writeroom-mode-map (kbd "C-M->") #'writeroom-increase-width)
    (define-key writeroom-mode-map (kbd "C-M-=") #'writeroom-adjust-width)))

(leaf org-id
  :after org
  :config
  ;; Auto-generate IDs for all headings when saving
  (setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id))



(defun live-shaping/auto-tangle-and-reload ()
  "When Emacs.org is saved, tangle it and reload init.el.
Handles errors gracefully and provides feedback."
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.config/emacs/Emacs.org"))
    (message "Live-Shaping: Tangling...")
    (condition-case tangle-err
        (progn
          ;; Attempt to tangle the org file
          (let ((tangle-result (org-babel-tangle)))
            (if tangle-result
                (progn
                  (message "Live-Shaping: Tangle successful. Reloading...")
                  (condition-case reload-err
                      (progn
                        (load-file "~/.config/emacs/init.el")
                        (message "Live-Shaping: Reload complete ✓"))
                    (error
                     (message "Live-Shaping: Reload failed: %s" 
                              (error-message-string reload-err))
                     (display-warning 'live-shaping
                                      (format "Failed to reload init.el: %s" 
                                              (error-message-string reload-err))
                                      :error))))
              (message "Live-Shaping: Tangle returned no files (check your source blocks)"))))
      (error
       (message "Live-Shaping: Tangle failed: %s" 
                (error-message-string tangle-err))
       (display-warning 'live-shaping
                        (format "Failed to tangle Emacs.org: %s" 
                                (error-message-string tangle-err))
                        :error)))))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)
