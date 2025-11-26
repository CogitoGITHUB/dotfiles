(add-to-list 'load-path "~/.config/emacs/lib/leaf")
  (require 'leaf)
 ;; You can also configure builtin package via leaf!
(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :custom ((user-full-name . "")
           (user-mail-address . "")
           (user-login-name . "")
           (truncate-lines . t)
           (menu-bar-mode . nil)
           (tool-bar-mode . nil)
           (scroll-bar-mode . nil)
           (indent-tabs-mode . nil)
           (window-divider-mode . nil)
           (window-divider-default-right-width . 1)
           (window-divider-default-bottom-width . 1)))

(leaf org-superstar
  :load-path "~/.config/emacs/lib/org-superstar-mode"
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  ((org-superstar-headline-bullets-list . '(?Ⅰ ?Ⅱ ?Ⅲ ?Ⅳ ?Ⅴ ?Ⅵ ?Ⅶ ?Ⅷ))
   (org-superstar-remove-leading-stars . t)
   (org-superstar-leading-fallback . ?\s))
  :config
  (custom-set-faces
   ;; bullets pure black — no hue, no compromise
   '(org-superstar-header-bullet ((t (:foreground "#000000" :weight bold :height 1.3))))
   '(org-superstar-item ((t (:foreground "#000000"))))
   '(org-superstar-leading ((t (:foreground "#000000"))))))

(leaf font-config
  :config
  ;; Set main font - try these in order of preference
  (cond
   ((find-font (font-spec :name "DejaVu Sans Mono"))
    (set-face-attribute 'default nil :font "DejaVu Sans Mono" :height 100)))
  
  ;; Set fallback font for Unicode symbols
  (set-fontset-font t 'unicode "Symbola" nil 'prepend)
  (set-fontset-font t 'unicode "Noto Sans Symbols" nil 'prepend))

(leaf evil
  :load-path "~/.config/emacs/lib/evil"
  :require evil
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t)
  :config
  (evil-mode 1)

  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)
    (define-key evil-normal-state-map (kbd "t") 'evil-next-line)
    (define-key evil-normal-state-map (kbd "n") 'evil-previous-line)
    (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)

    (define-key evil-motion-state-map (kbd "h") 'evil-backward-char)
    (define-key evil-motion-state-map (kbd "t") 'evil-next-line)
    (define-key evil-motion-state-map (kbd "n") 'evil-previous-line)
    (define-key evil-motion-state-map (kbd "s") 'evil-forward-char)))

  
  (leaf annalist
    :load-path "~/.config/emacs/lib/annalist"
    :require annalist)

  (leaf evil-collection
    :load-path "~/.config/emacs/lib/evil-collection"
    :after evil
    :require evil-collection
    :config
    (evil-collection-init))

  (leaf evil-surround
    :load-path "~/.config/emacs/lib/evil-surround"
    :require evil-surround
    :config
    (global-evil-surround-mode 1))

;; Where Emacs keeps the desktop session
(setq desktop-dirname "~/.config/emacs/desktop/"
      desktop-path   '("~/.config/emacs/desktop/")
      desktop-base-file-name "emacs-desktop")

;; Make sure the directory exists (safe even if it already does)
(make-directory desktop-dirname t)

(leaf desktop
  :require desktop
  :config
  ;; Save the desktop automatically on exit
  (add-hook 'kill-emacs-hook #'desktop-save-in-desktop-dir)

  ;; How eager to restore (higher = more buffers at once)
  (setq desktop-restore-eager 8
        desktop-lazy-idle-delay 0.5
        desktop-load-locked-desktop t)

  ;; Actually turn it on
  (desktop-save-mode 1))

(leaf pulsar
  :load-path "~/.config/emacs/lib/pulsar"
  :require pulsar
  :after pulsar
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
  :load-path "~/.config/emacs/lib/switch-window"
  :require switch-window
  :bind
  ("C-x w" . switch-window)
  :config
  (setq switch-window-shortcut-style 'qwerty
        switch-window-timeout nil
        switch-window-threshold 2))

(leaf ace-jump-mode
  :load-path "~/.config/emacs/lib/ace-jump-mode"
  :require ace-jump-mode
  :init
  ;; Before any jump, announce movement / integrate with visual pulse systems
  ;; (add-hook 'ace-jump-mode-before-jump-hook
            ;; (lambda () (message "shapeshift — jump engaged")))
  :config
  ;; target search across all windows
  (setq ace-jump-mode-scope 'global)
  ;; disable gray background (clean screen)
  (setq ace-jump-mode-gray-background nil)

  ;; do not ignore case in words
  (setq ace-jump-mode-case-fold t)

  ;; Dvorak home-row jump keys (optional, uncomment if desired)
  (setq ace-jump-mode-move-keys
        (string-to-list "aoeuidhtns"))

  ;; Evil modal bindings — spacebar becomes teleport
  (define-key evil-normal-state-map (kbd "SPC") 'ace-jump-mode)
  (define-key evil-visual-state-map (kbd "SPC") 'ace-jump-mode)
  (define-key evil-motion-state-map (kbd "SPC") 'ace-jump-mode))

(leaf multiple-cursors
  :load-path "~/.config/emacs/lib/multiple-cursors"
  :require multiple-cursors
  :config
  ;; Evil + MC Movement
  (define-key evil-normal-state-map (kbd "g m n") 'mc/mark-next-like-this)
  (define-key evil-normal-state-map (kbd "g m p") 'mc/mark-previous-like-this)
  (define-key evil-normal-state-map (kbd "g m a") 'mc/mark-all-like-this)

  (define-key evil-visual-state-map (kbd "g m n") 'mc/mark-next-like-this)
  (define-key evil-visual-state-map (kbd "g m p") 'mc/mark-previous-like-this)

  ;; Edit multiple lines simultaneously
  (define-key evil-normal-state-map (kbd "g m l") 'mc/edit-lines)

  ;; Escape multiple cursors
  (define-key evil-normal-state-map (kbd "<escape>") 'mc/keyboard-quit)
  (define-key evil-visual-state-map (kbd "<escape>") 'mc/keyboard-quit))

(leaf move-text
  :load-path "~/.config/emacs/lib/move-text"
  :require move-text
  :bind
  ("M-<up>"   . move-text-up)
  ("M-<down>" . move-text-down)
  :config
  ;; Evil integration
  (define-key evil-normal-state-map (kbd "M-<up>")   'move-text-up)
  (define-key evil-normal-state-map (kbd "M-<down>") 'move-text-down)
  (define-key evil-visual-state-map (kbd "M-<up>")   'move-text-up)
  (define-key evil-visual-state-map (kbd "M-<down>") 'move-text-down))

(defun indent-region-advice (&rest _ignored)
  (let ((deactivate deactivate-mark))
    (if (region-active-p)
        (indent-region (region-beginning) (region-end))
      (indent-region (line-beginning-position) (line-end-position)))
    (setq deactivate-mark deactivate)))

(advice-add 'move-text-down :after #'indent-region-advice)
(advice-add 'move-text-up   :after #'indent-region-advice)

(leaf undo-fu
  :load-path "~/.config/emacs/lib/undo-fu"
  :require undo-fu
  :init
  ;; Make Evil use undo-fu instead of built-in diff-based undo
  (setq evil-undo-system 'undo-fu)
  :config
  ;; Clear default binding
  (global-unset-key (kbd "C-z"))

  ;; Undo & Redo
  (global-set-key (kbd "C-z")   #'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") #'undo-fu-only-redo))

(define-key evil-normal-state-map (kbd "u") #'undo-fu-only-undo)
(define-key evil-normal-state-map (kbd "U") #'undo-fu-only-redo)

(use-package undo-fu-session
  :ensure t
  :config
  ;; Enable for all buffers by default
  (undo-fu-session-global-mode)

  ;; Customize storage directory
  (setq undo-fu-session-directory
        (expand-file-name "undo-sessions/" user-emacs-directory))

  ;; Limit number of session files to avoid clutter
  (setq undo-fu-session-file-limit 100)

  ;; Exclude specific files/modes
  (setq undo-fu-session-incompatible-major-modes
        '(magit-status-mode
          dired-mode))
  (setq undo-fu-session-incompatible-files
        '("/COMMIT_EDITMSG\\'"
          "\\.tmp\\'"))

  ;; Choose compression
  (setq undo-fu-session-compression 'zstd)  ;; or 'gz, 'bz2, nil

  ;; Use linear undo history only (optional)
  ;; (setq undo-fu-session-linear t)
  )

(leaf undo-fu-session
  :load-path "~/.config/emacs/lib/undo-fu-session"
  :require undo-fu-session
  :custom
  (undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'"
                                        "/git-rebase-todo\\'"))
  :config
  (undo-fu-session-global-mode 1))

(leaf yasnippet
  :load-path "~/.config/emacs/lib/yasnippet"
  :require yasnippet
  :config
  ;; Snippet directory configuration
  (setq yas-snippet-dirs
        (list (expand-file-name "snippets" "~/.config/emacs/")
              (expand-file-name "snippets"
                                (file-name-directory (locate-library "yasnippet")))))

  ;; Enable globally
  (yas-reload-all)
  (yas-global-mode 1)

  ;; Expansion trigger
  (define-key yas-minor-mode-map (kbd "TAB") 'yas-expand))

(leaf auto-yasnippet
  :load-path "~/.config/emacs/lib/auto-yasnippet"
  :require auto-yasnippet
  :bind
  ("C-c y w" . aya-create)  ;; create snippet from region
  ("C-c y e" . aya-expand)  ;; expand created snippet
  :config
  (setq aya-persist-snippets t
        aya-persist-directory (expand-file-name "auto-snippets" "~/.config/emacs/")))

(leaf evil-nerd-commenter
  :load-path "~/.config/emacs/lib/evil-nerd-commenter"
  :require evil-nerd-commenter
  :after evil
  :config
  ;; text object for comment
  (setq evilnc-comment-text-object "c")

  ;; default hotkeys provided by package
  (evilnc-default-hotkeys)

  ;; manual evil bindings
  (define-key evil-normal-state-map (kbd "gc")
              'evilnc-comment-or-uncomment-lines)
  (define-key evil-visual-state-map (kbd "gc")
              'evilnc-comment-or-uncomment-lines)
  (define-key evil-normal-state-map (kbd "gC")
              'evilnc-copy-and-comment-lines))

(leaf treesit-auto
  :load-path "~/.config/emacs/lib/treesit-auto"
  :require treesit-auto
  :config
  ;; Auto-install grammar (prompt each time)
  (setq treesit-auto-install 'prompt)

  ;; Add tree-sitter modes to auto-mode-alist intelligently
  (treesit-auto-add-to-auto-mode-alist 'all)

  ;; Enable global treesit handler
  (global-treesit-auto-mode 1))

(leaf dap-mode
  :load-path "~/.config/emacs/lib/dap-mode"
  :require dap-mode
  :after lsp-mode
  :config
  ;; Enable core debugging infrastructure
  (dap-mode 1)

  ;; Debug UI overlays and controls
  (dap-ui-mode 1)

  ;; Auto configuration
  (setq dap-auto-configure-mode t
        dap-auto-configure-features '(sessions locals controls tooltip))

  ;; Keybindings — home-row friendly
  (define-key dap-mode-map (kbd "C-c d d") #'dap-debug)
  (define-key dap-mode-map (kbd "C-c d b") #'dap-breakpoint-toggle)
  (define-key dap-mode-map (kbd "C-c d n") #'dap-continue)
  (define-key dap-mode-map (kbd "C-c d s") #'dap-step-in)
  (define-key dap-mode-map (kbd "C-c d o") #'dap-step-out))

(leaf which-key
  :load-path "~/.config/emacs/lib/which-key"
  :require which-key
  :config
  (which-key-mode 1))

(leaf flycheck
  :load-path "~/.config/emacs/lib/flycheck"
  :hook (after-init-hook . global-flycheck-mode)
  :config
  (global-flycheck-mode +1))

(leaf projectile
  :load-path "~/.config/emacs/lib/projectile"
  :load-path "~/.config/emacs/lib/projectile/lisp"
  :config
  (require 'projectile)
  (projectile-mode +1)

  (setq projectile-keymap-prefix (kbd "C-c p"))

  (setq projectile-project-search-path '("~/Projects" "~/Shapeless-Links" "~/AeonCore"))
  (setq projectile-completion-system 'default)
  (setq projectile-enable-caching t)

  (when (executable-find "rg")
    (setq projectile-generic-command "rg -0 --files --color=never"))

  (define-key projectile-mode-map (kbd "C-c p f") #'projectile-find-file)
  (define-key projectile-mode-map (kbd "C-c p p") #'projectile-switch-project)
  (define-key projectile-mode-map (kbd "C-c p b") #'projectile-switch-to-buffer))

(leaf compat
  :load-path "~/.config/emacs/lib/compat"
  :require t)

(leaf org-timeblock
  :after org
  :load-path "~/.config/emacs/lib/org-timeblock"
  :require t
  :commands org-timeblock
  :config
  (setq org-timeblock-files '("~/Shapeless-Links/"
                              "~/Projects/"))
  (setq org-timeblock-span 3))

(leaf dslide
  :load-path "~/.config/emacs/lib/dslide"
  :require t
  :commands (dslide-deck-start dslide-deck-forward dslide-deck-backward)
  :config
  ;; Keybindings for slide navigation
  (define-key dslide-mode-map (kbd "<right>") #'dslide-deck-forward)
  (define-key dslide-mode-map (kbd "<left>")  #'dslide-deck-backward)
  (define-key dslide-mode-map (kbd "<up>")    #'dslide-deck-start)
  (define-key dslide-mode-map (kbd "<down>")  #'dslide-deck-stop)

  ;; Ritual mode: invocation when the deck opens
  (add-hook 'dslide-start-hook
            (lambda ()
              (visual-fill-column-mode 1)
              (variable-pitch-mode 1)))
  )

(leaf pdf-tools
  :load-path "~/.config/emacs/lib/pdf-tools/lisp"
  :require t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-tools-install)
  :config
  (setq pdf-tools-handle-upgrades t)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)

  ;; Navigation bindings
  (define-key pdf-view-mode-map (kbd "h") #'pdf-view-previous-page)
  (define-key pdf-view-mode-map (kbd "l") #'pdf-view-next-page)
  (define-key pdf-view-mode-map (kbd "SPC") #'pdf-view-scroll-up-or-next-page)
  (define-key pdf-view-mode-map (kbd "b") #'pdf-view-scroll-down-or-previous-page))

(leaf pdf-view-restore
  :load-path "~/.config/emacs/lib/pdf-view-restore"
  :after pdf-tools
  :require t
  :config
  (pdf-view-restore-mode 1)
  (setq pdf-view-restore-data-file
        (expand-file-name "pdf-view-restore-data.el"
                          user-emacs-directory)))

(leaf auctex
  :load-path "~/.config/emacs/lib/auctex"
  :hook
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . turn-on-reftex)
  (LaTeX-mode . visual-line-mode)
  (LaTeX-mode . flyspell-mode)
  :config
  (setq TeX-PDF-mode t)
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil
        TeX-source-correlate-mode t
        TeX-source-correlate-method 'synctex
        LaTeX-indent-environment-check nil
        TeX-engine 'luatex
        reftex-plug-into-AUCTeX t))

(leaf latex-preview-pane
  :load-path "~/.config/emacs/lib/latex-preview-pane"
  :hook
  (latex-mode . latex-preview-pane-enable)
  :config
  (setq latex-preview-pane-multifile-mode t
        latex-preview-pane-use-ac-math t)
  (latex-preview-pane-enable))

(leaf math-preview
  :load-path "~/.config/emacs/lib/math-preview"
  :commands (math-preview-all math-preview-region math-preview-at-point)
  :config
  (setq math-preview-command "/usr/local/bin/math-preview")
  (define-key org-mode-map   (kbd "SPC m p") #'math-preview-at-point)
  (define-key latex-mode-map (kbd "SPC m p") #'math-preview-at-point))

(leaf s
  :load-path "~/.config/emacs/lib/s")

(leaf ht
  :load-path "~/.config/emacs/lib/ht")

(leaf treepy
  :load-path "~/.config/emacs/lib/treepy")

(leaf closql
  :load-path "~/.config/emacs/lib/closql")

(leaf ghub
  :after (s ht closql)
  :load-path "~/.config/emacs/lib/ghub/lisp")

(leaf forge
  :after ghub
  :load-path "~/.config/emacs/lib/forge/lisp")

(leaf modus-themes
  :load-path "/home/asdf/.config/emacs/lib/modus-themes"
  :init
  (setq modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-org-blocks 'gray-background
        modus-themes-fringes 'intense)
  :config
  (load-theme 'modus-operandi :no-confirm)

  (defun shapeshift/monochrome-world ()
    "Force Emacs into strict black-on-white."
    ;; canvas
    (set-face-attribute 'default nil
                        :foreground "#000000"
                        :background "#ffffff")

    ;; org headings big + bold + monochrome
    (set-face-attribute 'org-level-1 nil :foreground "#000000" :weight 'bold :height 1.80 :inherit nil)
    (set-face-attribute 'org-level-2 nil :foreground "#000000" :weight 'bold :height 1.60 :inherit nil)
    (set-face-attribute 'org-level-3 nil :foreground "#000000" :weight 'bold :height 1.40 :inherit nil)
    (set-face-attribute 'org-level-4 nil :foreground "#000000" :weight 'bold :height 1.25 :inherit nil)
    (set-face-attribute 'org-level-5 nil :foreground "#000000" :weight 'bold :height 1.10 :inherit nil)
    (set-face-attribute 'org-level-6 nil :foreground "#000000" :weight 'bold :height 1.05 :inherit nil)
    (set-face-attribute 'org-level-7 nil :foreground "#000000" :weight 'bold :height 1.05 :inherit nil)
    (set-face-attribute 'org-level-8 nil :foreground "#000000" :weight 'bold :height 1.05 :inherit nil)
    (set-face-attribute 'org-document-title nil :foreground "#000000" :weight 'bold :height 2.0 :inherit nil)

    ;; links stripped
    (set-face-attribute 'org-link nil :underline nil :inherit nil)

    ;; syntax
    (dolist (face '(font-lock-comment-face
                    font-lock-string-face
                    font-lock-keyword-face
                    font-lock-function-name-face
                    font-lock-variable-name-face
                    font-lock-type-face
                    font-lock-constant-face))
      (set-face-attribute face nil :foreground "#000000"))

    ;; dired — bold architecture for directories
    (set-face-attribute 'dired-directory nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-symlink nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-mark nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-marked nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-flagged nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-warning nil :foreground "#000000" :weight 'bold :inherit nil)
    (set-face-attribute 'dired-perm-write nil :foreground "#000000" :inherit nil)
    (set-face-attribute 'dired-special nil :foreground "#000000" :inherit nil))

  ;; Apply immediately
  (shapeshift/monochrome-world)

  ;; Reapply after any theme reload
  (advice-add 'load-theme :after
              (lambda (&rest _)
                (shapeshift/monochrome-world))))

(leaf visual-fill-column
  :load-path "~/.config/emacs/lib/visual-fill-column"
  :require t)

(leaf writeroom-mode
  :load-path "~/.config/emacs/lib/writeroom-mode"
  :global-minor-mode global-writeroom-mode
  :config

  ;; disable all frame/global side-effects
  (setq writeroom-global-effects nil)
  (setq writeroom-maximize-window nil)
  (setq writeroom-mode-line nil)
  (setq writeroom-bottom-divider-width 0)

  ;; evil-style width control bindings
  (with-eval-after-load 'writeroom-mode
    (define-key writeroom-mode-map (kbd "C-M-<") #'writeroom-decrease-width)
    (define-key writeroom-mode-map (kbd "C-M->") #'writeroom-increase-width)
    (define-key writeroom-mode-map (kbd "C-M-=") #'writeroom-adjust-width)))

(leaf centered-cursor-mode
  :load-path "/home/asdf/.config/emacs/lib/centered-cursor-mode"
  :global-minor-mode t)

(leaf dash
  :load-path "~/.config/emacs/lib/dash"
  :require t)
(leaf org-roam
  :load-path "~/.config/emacs/lib/org-roam"
  :after (org dash)
  :require t
  :custom
  ((org-roam-directory . "~/Roam/")
   (org-roam-db-location . "~/.config/emacs/org-roam.db")
   (org-roam-completion-everywhere . t))
  :config
  (org-roam-db-autosync-enable)

  (define-key global-map (kbd "C-c r f") #'org-roam-node-find)
  (define-key global-map (kbd "C-c r i") #'org-roam-node-insert)
  (define-key global-map (kbd "C-c r g") #'org-roam-graph)
  (define-key global-map (kbd "C-c r d") #'org-roam-dailies-map)
  (define-key global-map (kbd "C-c r t") #'org-roam-dailies-capture-today))

(leaf org-roam-ui
  :load-path "~/.config/emacs/lib/org-roam-ui"
  :after org-roam
  :require t
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(defun live-shaping/auto-tangle-and-reload ()
  "When Emacs.org is saved, tangle it and reload init.el."
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.config/emacs/Emacs.org"))
    (message "Live-Shaping: Tangling & Reloading...")
    (org-babel-tangle)
    (load-file "~/.config/emacs/init.el")
    (message "Live-Shaping: Reload complete.")))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)
