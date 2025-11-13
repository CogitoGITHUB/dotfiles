;;; init.el --- Monochrome Emacs Cathedral -*- lexical-binding: t; -*-
(add-to-list 'default-frame-alist '(undecorated . t))

;; --- Basic Environment -------------------------------------------------
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      visible-bell nil
      frame-resize-pixelwise t
      read-process-output-max (* 1024 1024)  ; 1MB
      gc-cons-threshold (* 100 1024 1024)
      gc-cons-percentage 0.6)

(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1))

(global-visual-line-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)

;; --- Monochrome look ---------------------------------------------------
(mapc #'disable-theme custom-enabled-themes)
(setq custom-safe-themes t)

(set-face-attribute 'default nil
                    :background "#FFFFFF"
                    :foreground "#000000"
                    :weight 'normal
                    :slant 'normal)

(defun shapeshifter/monochrome-reset ()
  "Reset all faces to inherit default black-on-white settings."
  (dolist (face (face-list))
    (set-face-attribute face nil
                        :foreground 'unspecified
                        :background 'unspecified
                        :underline nil
                        :box nil
                        :weight 'normal
                        :slant 'normal))
  (set-face-attribute 'region nil :background "#DDDDDD" :extend t)
  (set-face-attribute 'hl-line nil :background "#F2F2F2" :extend t)
  (set-face-attribute 'show-paren-match nil
                      :background "#CCCCCC" :foreground "#000000" :weight 'normal)
  (set-face-attribute 'show-paren-mismatch nil
                      :background "#FFAAAA" :foreground "#000000" :weight 'normal))
(add-hook 'after-init-hook #'shapeshifter/monochrome-reset)
(add-hook 'after-change-major-mode-hook #'shapeshifter/monochrome-reset)

(global-font-lock-mode 1)
(setq font-lock-maximum-decoration t)

;; --- Header line (centered buffer name) -------------------------------
(defun shapeshifter/headerline-center ()
  "Centered buffer name for header-line."
  (let* ((name (or (buffer-name) ""))
         (width (or (ignore-errors (window-total-width)) 80))
         (pad (/ (max 0 (- width (length name))) 2)))
    (concat (make-string pad ?\s) name)))
(setq-default header-line-format '((:eval (shapeshifter/headerline-center))))

;; --- Disable ANSI colors ----------------------------------------------
(setq ansi-color-for-comint-mode nil)
(defun shapeshifter/noop-ansi (string)
  (if (stringp string) string ""))
(advice-add 'ansi-color-apply :override #'shapeshifter/noop-ansi)

;; --- Backups / autosaves clean ----------------------------------------
(let* ((var-dir (expand-file-name "var/" user-emacs-directory))
       (bk-dir  (expand-file-name "backup/" var-dir))
       (as-dir  (expand-file-name "autosave/" var-dir)))
  (dolist (d (list var-dir bk-dir as-dir))
    (unless (file-directory-p d) (make-directory d t)))
  (setq backup-directory-alist `(("." . ,bk-dir))
        auto-save-file-name-transforms `((".*" ,as-dir t))
        auto-save-list-file-prefix (expand-file-name "saves-" as-dir)
        create-lockfiles nil
        make-backup-files t
        delete-old-versions t
        version-control t))

;; --- Quality of life ---------------------------------------------------
(defalias 'yes-or-no-p 'y-or-n-p)
(savehist-mode 1)
(recentf-mode 1)
(setq recentf-max-saved-items 200)

(provide 'init)
;;; init.el ends here


;;; Load modular package configs
(let ((pkg-dir (expand-file-name "packages" user-emacs-directory)))
  (when (file-directory-p pkg-dir)
    (add-to-list 'load-path pkg-dir)
    (dolist (file (directory-files pkg-dir t "\\.el$"))
      (load (file-name-sans-extension file)))))
