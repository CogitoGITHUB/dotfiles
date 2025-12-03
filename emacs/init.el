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
  (require 'org)
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
(setq-default mode-line-format nil)
(setq mode-line-format nil)

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

(leaf font-config
  :config
  (defun shapeshift/apply-fonts ()
    (when (display-graphic-p)

      ;; ---------------------------------
      ;; PURE CALLIGRAPHY – THE ONE FONT
      ;; ---------------------------------
      (when (find-font (font-spec :name "Tangerine"))
        (set-face-attribute 'default nil
                            :family "Tangerine"
                            :height 110)
        (set-face-attribute 'variable-pitch nil
                            :family "Tangerine"
                            :height 110)
        (set-face-attribute 'fixed-pitch nil
                            :family "Tangerine"
                            :height 110)))

      ;; ---------------------------------
      ;; LIVING UNICODE FALLBACKS
      ;; ---------------------------------
      (set-fontset-font t 'unicode "Noto Sans Symbols" nil 'prepend)
      (set-fontset-font t 'unicode "Noto Sans" nil 'append)
      (set-fontset-font t 'unicode "Noto Sans Mono" nil 'append)
      (set-fontset-font t 'unicode "Noto Color Emoji" nil 'append)))

  (add-hook 'after-make-frame-functions
            (lambda (_frame) (shapeshift/apply-fonts)))

  (shapeshift/apply-fonts)

(leaf evil
  :straight (evil :type git :host github :repo "emacs-evil/evil" :branch "master" :fetch t)
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t)
  :config
  (evil-mode 1)

  ;; h t n s directional compass
  (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)
  (define-key evil-normal-state-map (kbd "t") 'evil-next-line)
  (define-key evil-normal-state-map (kbd "n") 'evil-previous-line)
  (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)

  (define-key evil-motion-state-map (kbd "h") 'evil-backward-char)
  (define-key evil-motion-state-map (kbd "t") 'evil-next-line)
  (define-key evil-motion-state-map (kbd "n") 'evil-previous-line)
  (define-key evil-motion-state-map (kbd "s") 'evil-forward-char)

  ;; SPACE as leader
  (define-key evil-normal-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil)

  (defvar shapeshifter-leader-map (make-sparse-keymap)
    "Shapeshifter Leader keymap.")

  (define-key evil-normal-state-map (kbd "SPC") shapeshifter-leader-map)
  (define-key evil-motion-state-map (kbd "SPC") shapeshifter-leader-map)

  ;; Core leader bindings
  (define-key shapeshifter-leader-map (kbd "f") #'find-file)
  (define-key shapeshifter-leader-map (kbd "s") #'save-buffer)
  (define-key shapeshifter-leader-map (kbd "g") #'magit-status)
  (define-key shapeshifter-leader-map (kbd "b") #'switch-to-buffer)
  (define-key shapeshifter-leader-map (kbd "k") #'kill-buffer)
  (define-key shapeshifter-leader-map (kbd "j") #'avy-goto-char-timer))
(leaf annalist
  :straight (annalist :type git :host github :repo "noctuid/annalist.el" :fetch t))

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
  (setq avy-background nil        ; do not dim background
        avy-all-windows t         ; jump across windows
        avy-style 'at-full        ; full precision hints
        avy-timeout-seconds 0.4)

  (setq avy-keys (string-to-list "aoeuidhtns")) ; home row Dvorak

  ;; minimal neutral look
  (custom-set-faces
   '(avy-lead-face   ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-0 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-1 ((t (:foreground "#000000" :background "#cccccc" :weight normal))))
   '(avy-lead-face-2 ((t (:foreground "#000000" :background "#cccccc" :weight normal)))))

  ;; dispatch — surgical actions mid-jump
  (setq avy-dispatch-alist
        '((?k . avy-kill-region)
          (?y . avy-copy-region)
          (?c . avy-kill-ring-save)))
)

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

(leaf org-transclusion
  :straight (org-transclusion
             :type git
             :host github
             :repo "nobiot/org-transclusion")
  :after org
  :config
  ;; Auto-enable in Org buffers (optional; comment out if too much)
  (add-hook 'org-mode-hook #'org-transclusion-mode)

  ;; Quick keybindings for operations
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c t a") #'org-transclusion-add)
    (define-key org-mode-map (kbd "C-c t u") #'org-transclusion-refresh)))

;;────────────────────────────────────────────────────────────
;; Denote — Clean configuration, no inline templates
;;────────────────────────────────────────────────────────────
;;────────────────────────────────────────────────────────────
;; Org-ID — persistent identity
;;────────────────────────────────────────────────────────────
(leaf org-id
  :after org
  :config
  (setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id))

;;────────────────────────────────────────────────────────────
;; Org-Roam — neural map engine
;;────────────────────────────────────────────────────────────
(leaf org-roam
  :straight (org-roam
             :type git
             :host github
             :repo "org-roam/org-roam")
  :after org
  :init
  ;; CRITICAL: Point Org-Roam to your Denote directory
  (setq org-roam-directory (file-truename "~/denote"))
  (setq find-file-visit-truename t)
  (setq org-roam-v2-ack t)
  :config
  ;; Awaken the database watcher
  (org-roam-db-autosync-mode))

;;────────────────────────────────────────────────────────────
;; Denote Configuration (updated)
;;────────────────────────────────────────────────────────────
 (leaf denote
  :straight (denote :type git :host github :repo "protesilaos/denote")
  :after org
  :init
  ;; Base directory for all notes (shared with Org-Roam)
  (setq denote-directory (expand-file-name "~/denote"))
  ;; File format + naming
  (setq denote-file-type 'org)
  (setq denote-date-format "%Y-%m-%d--%H-%M")
  ;; Prompts: title, keywords, subdirectory, signature
  (setq denote-prompts '(title keywords subdirectory signature))
  ;; Org appearance
  (setq org-startup-with-inline-images nil)
  (setq org-startup-folded 'showall)
  :config
  ;; Ensure directory exists
  (unless (file-directory-p denote-directory)
    (make-directory denote-directory t))

  ;; Auto rename buffers to meaningful Denote names
  (denote-rename-buffer-mode 1)

  ;; Backlinks rendering behavior
  (setq denote-link-backlinks-display-buffer-action
        '((display-buffer-reuse-window display-buffer-below-selected)
          (window-height . fit-window-to-buffer)))

  ;;────────── Subdirectory creation logic ──────────
  (defun my/denote-subdirectory-prompt ()
    "Prompt for a Denote subdirectory, creating it if needed."
    (let* ((subdirs (mapcar (lambda (dir)
                              (file-relative-name dir denote-directory))
                            (seq-filter #'file-directory-p
                                        (directory-files denote-directory t "^[^.]"))))
           (subdir (completing-read "Subdirectory (new or existing): "
                                    subdirs nil nil)))
      (let ((full-path (expand-file-name subdir denote-directory)))
        (unless (file-directory-p full-path)
          (when (yes-or-no-p (format "Create directory %s? " full-path))
            (make-directory full-path t)))
        full-path)))

  (advice-add 'denote-subdirectory-prompt :override #'my/denote-subdirectory-prompt)

  ;;────────── Helper function for capture (Org-roam compatible) ──────────
  (defun my/denote-capture-create-file ()
    "Create a Denote file as a valid Org-roam node and return its path for org-capture."
    (let* ((title (read-string "Title: "))
           (keywords (denote-keywords-prompt))
           (subdir (my/denote-subdirectory-prompt))
           (signature (read-string "Signature (optional): " nil nil ""))
           (date (current-time))
           ;; Denote ID (timestamp-style)
           (id (format-time-string denote-date-format date))
           (date-formatted (format-time-string denote-date-format date))
           (ext ".org")
           (kws (if keywords (concat "_" (mapconcat #'downcase keywords "_")) ""))
           (sig (if (string-empty-p signature) "" (concat "==" signature)))
           (slug (replace-regexp-in-string "[^[:alnum:][:digit:]]" "-" (downcase title)))
           (filename (concat id "--" slug kws sig ext))
           (path (expand-file-name filename subdir))
           ;; Org-roam UUID for the node
           (org-id (org-id-new))
           (frontmatter
            (concat
             "#+title:      " title "\n"
             "#+date:       " date-formatted "\n"
             "#+AUTHOR:     Shapeshifter\n"
             "#+identifier: " id "\n"
             "#+filetags:   "
             (if keywords (mapconcat #'identity keywords " ") "")
             "\n"
             (unless (string-empty-p signature)
               (concat "#+signature:  " signature "\n"))
             "\n"
             "* " title "\n"
             ":PROPERTIES:\n"
             ":ID:       " org-id "\n"
             ":END:\n\n")))
      ;; write file
      (write-region frontmatter nil path)
      path)))

;;────────────────────────────────────────────────────────────
;; Org-Capture Templates
;;────────────────────────────────────────────────────────────
(with-eval-after-load 'denote
  (with-eval-after-load 'org-capture
    (setq org-capture-templates
          '(("n" "New Denote Note" plain
             (file my/denote-capture-create-file)
             ""
             :empty-lines 1
             :jump-to-captured t)))))

;;────────────────────────────────────────────────────────────
;; Leader Keybindings (Denote + Org-Roam)
;;────────────────────────────────────────────────────────────
(with-eval-after-load 'denote
  (with-eval-after-load 'evil
    ;; DENOTE keybindings
    (define-key evil-normal-state-map (kbd "SPC n n")
      (lambda () (interactive) (org-capture nil "n")))
    (define-key evil-normal-state-map (kbd "SPC n c") #'denote)
    (define-key evil-visual-state-map (kbd "SPC n R") #'denote-region)
    (define-key evil-normal-state-map (kbd "SPC n r") #'denote-rename-file)
    (define-key evil-normal-state-map (kbd "SPC n S")
      #'denote-rename-file-using-front-matter)
    (define-key evil-normal-state-map (kbd "SPC n d")
      (lambda () (interactive) (dired denote-directory)))
    (define-key evil-normal-state-map (kbd "SPC n s") #'denote-subdirectory)
    
    ;; LINKING: Use both Denote and Org-Roam
    (define-key evil-normal-state-map (kbd "SPC n l") #'denote-link)
    (define-key evil-normal-state-map (kbd "SPC n L") #'denote-link-add-links)
    
    ;; BACKLINKS: Denote backlinks
    (define-key evil-normal-state-map (kbd "SPC n b") #'denote-backlinks)
    
    (define-key evil-normal-state-map (kbd "SPC n e")
      (lambda () (interactive) (dired denote-directory)))
    (define-key evil-normal-state-map (kbd "SPC n k") #'kill-current-buffer)))

;; ORG-ROAM keybindings (separate prefix)
(with-eval-after-load 'org-roam
  (with-eval-after-load 'evil
    ;; Find/insert Org-Roam node
    (define-key evil-normal-state-map (kbd "SPC r f") #'org-roam-node-find)
    (define-key evil-normal-state-map (kbd "SPC r i") #'org-roam-node-insert)
    
    ;; Org-Roam backlinks buffer (graph view)
    (define-key evil-normal-state-map (kbd "SPC r b") #'org-roam-buffer-toggle)
    
    ;; Show graph UI
    (define-key evil-normal-state-map (kbd "SPC r g") #'org-roam-ui-mode)
    
    ;; Sync database
    (define-key evil-normal-state-map (kbd "SPC r s") #'org-roam-db-sync)))

(leaf denote-explore
  :straight (denote-explore
             :type git
             :host github
             :repo "pprevos/denote-explore")
  :after denote
  :config
  (global-set-key (kbd "C-c d e") #'denote-explore)
  (global-set-key (kbd "C-c d b") #'denote-explore-backlinks))

(leaf consult-denote
  :straight (consult-denote
             :type git
             :host github
             :repo "protesilaos/consult-denote")
  :after (denote consult)
  :config
  ;; Use Consult for completing/jumping across Denote notes
  (global-set-key (kbd "C-c d f") #'consult-denote)

  ;; Optional: narrow by keyword/tag quickly
  (global-set-key (kbd "C-c d F") #'consult-denote-file))

(leaf org-roam-ui
  :straight (org-roam-ui
             :type git
             :host github
             :repo "org-roam/org-roam-ui"
             :files ("*.el" "out"))
  :after org-roam  ;; ensure Roam loads first
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t)

  ;; open UI immediately when Emacs finishes startup
  (add-hook 'emacs-startup-hook #'org-roam-ui-mode))

;;──────────────────────────────────────────────────────────
;; LaTeX Manuscript Mode (Safe, Non-recursive, Precise)
;;──────────────────────────────────────────────────────────

(leaf cdlatex
  :straight (cdlatex :type git :host github :repo "cdominik/cdlatex"))

(leaf org-fragtog
  :straight (org-fragtog :type git :host github :repo "io12/org-fragtog"))

(leaf auctex
  :straight (auctex :type git :host github :repo "emacs-straight/auctex"))

(leaf pdf-tools
  :straight (pdf-tools :type git :host github :repo "vedang/pdf-tools")
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-tools-install)
  :config
  (setq pdf-view-display-size 'fit-page))

;; Global protection against TeX trying to use ~/.emacs as master
(setq-default TeX-master nil)

(defvar shapeshift/org-latex-export-timer nil)

(defun shapeshift/show-pdf-in-split (pdf)
  "Open PDF preview buffer in a split window without marking it visited."
  (delete-other-windows)
  (split-window-right)
  (other-window 1)
  (let* ((buffer (find-file-noselect pdf)))
    (with-current-buffer buffer
      (pdf-view-mode)
      (auto-revert-mode 1)
      (setq buffer-read-only t)
      (setq revert-without-query '(".*\\.pdf")))
    (switch-to-buffer buffer))
  (other-window -1))

(defun shapeshift/org-export-and-preview-split ()
  "Export Org to PDF and preview in split window with idle delay."
  (interactive)
  (when shapeshift/org-latex-export-timer
    (cancel-timer shapeshift/org-latex-export-timer))
  (setq shapeshift/org-latex-export-timer
        (run-with-idle-timer
         0.4 nil
         (lambda ()
           (let* ((org-file (buffer-file-name))
                  (pdf (concat (file-name-sans-extension org-file) ".pdf")))
             (org-latex-export-to-pdf)
             (when (file-exists-p pdf)
               (shapeshift/show-pdf-in-split pdf)
               (message "PDF updated ✓")))))))

(defun shapeshift/org-latex-manuscript-mode ()
  "Enable Live-Shaping manuscript preview workflow."
  (interactive)
  (visual-line-mode 1)
  (org-cdlatex-mode 1)
  (org-fragtog-mode 1)
  (setq-local TeX-command-extra-options "-shell-escape")
  (shapeshift/org-export-and-preview-split)
  (add-hook 'after-save-hook #'shapeshift/org-export-and-preview-split nil t)
  (message "Manuscript mode enabled: Split live preview"))

(defun shapeshift/maybe-enable-manuscript-mode ()
  "Enable manuscript mode only for real LaTeX-bearing files, never Emacs.org."
  (when (and (eq major-mode 'org-mode)
             (buffer-file-name)
             (not (string-match-p "Emacs.org" (buffer-file-name)))
             (save-excursion
               (goto-char (point-min))
               (re-search-forward "^#\\+LATEX_CLASS:" nil t)))
    (shapeshift/org-latex-manuscript-mode)))

(add-hook 'org-mode-hook #'shapeshift/maybe-enable-manuscript-mode)
(leaf pdf-tools
  :straight (pdf-tools :type git :host github :repo "vedang/pdf-tools")
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook ((pdf-view-mode . pdf-tools-install))
  :config
  (unless (file-exists-p pdf-info-epdfinfo-program)
    (pdf-tools-install))
  (setq pdf-view-display-size 'fit-page))

;; ───────────────────────────────────────────────────────────────
;; CONSULT — the high-precision jump engine
;; ───────────────────────────────────────────────────────────────
(leaf consult
  :straight (consult
             :type git
             :host github
             :repo "minad/consult")
  :bind
  (("C-s"     . consult-line)              ;; search inside buffer
   ("C-c f"   . consult-find)              ;; find files
   ("C-c g"   . consult-git-grep)          ;; ripgrep
   ("C-x b"   . consult-buffer)            ;; buffer switcher
   ("C-x r b" . consult-bookmark)          ;; bookmarks
   ))

;; ───────────────────────────────────────────────────────────────
;; EMBARK — the action layer (right-click for the keyboard age)
;; ───────────────────────────────────────────────────────────────
(leaf embark
  :straight (embark
             :type git
             :host github
             :repo "oantolin/embark")
  :bind
  (("C-." . embark-act)         ;; think: context menu, immediate action
   ("C-;" . embark-dwim)        ;; run best action automatically
   ("C-h B" . embark-bindings)) ;; see keymaps

  :config
  ;; nicer popups
  (setq embark-prompter 'embark-keymap-prompter))

;; live annotations for consult
(leaf embark-consult
  :straight (embark-consult
             :type git
             :host github
             :repo "oantolin/embark")
  :after (embark consult)
  :config
  (embark-consult-mode 1))
(with-eval-after-load 'consult
  (define-key shapeshifter-leader-map (kbd "u") #'consult-buffer)
  (define-key shapeshifter-leader-map (kbd "f") #'consult-find)
  (define-key shapeshifter-leader-map (kbd "b") #'consult-buffer)
  (define-key shapeshifter-leader-map (kbd "s") #'consult-ripgrep)
  (define-key shapeshifter-leader-map (kbd "l") #'consult-line))

;; ───────────────────────────────────────────────────────────────
;; ALL THE ICONS — full Git install, no MELPA, no missing files
;; ───────────────────────────────────────────────────────────────

(leaf all-the-icons
  :straight (all-the-icons
             :type git
             :host github
             :repo "domtronn/all-the-icons.el")
  :config
  ;; Install the fonts automatically if missing
  (unless (file-exists-p (expand-file-name "all-the-icons.ttf"
                                           (concat user-emacs-directory "fonts/")))
    (all-the-icons-install-fonts t)))

(leaf all-the-icons-dired
  :straight (all-the-icons-dired
             :type git
             :host github
             :repo "wyuenho/all-the-icons-dired")
  :hook (dired-mode . all-the-icons-dired-mode))

(leaf all-the-icons-completion
  :straight (all-the-icons-completion
             :type git
             :host github
             :repo "iyefrat/all-the-icons-completion")
  :after (all-the-icons marginalia)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :config
  (all-the-icons-completion-mode 1))

(defun live-shaping/auto-tangle-and-reload ()
  "Auto-tangle and reload when this Org file tangles to init.el."
  (when (and buffer-file-name
             (save-excursion
               (goto-char (point-min))
               (re-search-forward ":tangle[ \t]+~/.config/emacs/init.el" nil t)))
    (message "Live-Shaping: Tangling…")
    (condition-case err
        (let ((target "~/.config/emacs/init.el")
              (temp   "~/.config/emacs/init.el.tmp"))
          (when (org-babel-tangle)
            (when (file-exists-p temp) (delete-file temp))
            (rename-file target temp t)
            (rename-file temp target t)
            (load-file target)
            (message "Live-Shaping: Reload complete ✓")))
      (error
       (display-warning
        'live-shaping (format "%s" (error-message-string err)) :error)))))

(add-hook 'after-save-hook #'live-shaping/auto-tangle-and-reload)
