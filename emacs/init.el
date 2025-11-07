;;; ~/.emacs.d/init.el --- Monochrome Emacs Cathedral -*- lexical-binding: t; -*-
;;; Commentary:
;;  Precision configuration: no colors, no noise, full control.
;; --- Meta reference for Emacs to know where it lives
(defvar thisfile (or load-file-name buffer-file-name)
  "Path to this init.el, for internal references.")

;;  Uses straight.el + use-package + Magit.
;;; Code:

;; === Bootstrap straight.el ===
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; === Integrate use-package with straight.el ===
(setq straight-use-package-by-default t)
(straight-use-package 'use-package)
(require 'use-package)

;; === UI Tweaks ===
(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1))

(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      visible-bell nil)

(global-visual-line-mode 1)

;; === Performance tuning ===
(setq read-process-output-max (* 1024 1024)) ; 1MB
(setq gc-cons-threshold (* 100 1024 1024))   ; 100MB
(setq gc-cons-percentage 0.6)

;; === Disable all themes & colors ===
(mapc #'disable-theme custom-enabled-themes)
(setq custom-safe-themes t)

(set-face-attribute 'default nil
                    :background "#FFFFFF"
                    :foreground "#000000"
                    :weight 'normal
                    :slant 'normal)

(defun shapeshifter/monochrome-reset ()
  "Reset all faces to inherit the default black-on-white scheme safely."
  (mapatoms
   (lambda (sym)
     (when (facep sym)
       (set-face-attribute sym nil
                           :foreground 'unspecified
                           :background 'unspecified
                           :underline nil
                           :box nil
                           :weight 'normal
                           :slant 'normal)))))
(shapeshifter/monochrome-reset)

;; Completely disable syntax highlighting
(global-font-lock-mode -1)
(setq font-lock-support-mode nil
      font-lock-maximum-decoration nil)

;; === Make minibuffer and completion UI colorless ===
(dolist (face '(minibuffer-prompt
                completion-inline
                completions-common-part
                completions-highlight
                completions-first-difference
                completions-annotations
                completions-group-separator
                completions-group-title))
  (when (facep face)
    (set-face-attribute face nil
                        :foreground 'unspecified
                        :background 'unspecified
                        :weight 'normal
                        :slant 'normal
                        :underline nil
                        :box nil)))

;; === Disable ANSI color in shell, eshell, compilation, etc. ===
(setq ansi-color-for-comint-mode nil)
(setq ansi-color-names-vector [default default default default default default default default])
(advice-add 'ansi-color-apply :override #'identity)

;; === Prevent Emacs from touching ~/.emacs.d/custom.el ===
(setq custom-file (make-temp-file "emacs-custom"))

;; === Header line centered buffer name ===
(setq-default header-line-format
              '((:eval
                 (let* ((name (buffer-name))
                        (width (window-total-width))
                        (padding (/ (- width (length name)) 2)))
                   (concat (make-string (max 0 padding) ? ) name)))))

;; === Subtle Visual Feedback ===

;; Highlight selected region with soft gray
(set-face-attribute 'region nil
                    :background "#DDDDDD"
                    :foreground 'unspecified
                    :extend t)

;; Highlight the current line (light gray band)
(global-hl-line-mode 1)
(set-face-attribute 'hl-line nil
                    :background "#F2F2F2"
                    :foreground 'unspecified
                    :extend t)

;; Show matching parentheses
(setq show-paren-delay 0)
(setq show-paren-highlight-openparen t)
(setq show-paren-when-point-inside-paren t)
(setq show-paren-when-point-in-periphery t)
(show-paren-mode 1)

;; Matching parens are slightly gray — visual, not loud
(set-face-attribute 'show-paren-match nil
                    :background "#CCCCCC"
                    :foreground "#000000"
                    :weight 'normal
                    :underline nil)

(set-face-attribute 'show-paren-mismatch nil
                    :background "#FFAAAA"
                    :foreground "#000000"
                    :weight 'normal)


;; === Magit (via straight.el + use-package) ===
(use-package magit
  :straight (magit
             :type git
             :host github
             :repo "magit/magit")
  :commands (magit-status magit-blame magit-log)
  :init
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  :config
  (global-set-key (kbd "C-x g") #'magit-status))

(provide 'init)
;;; init.el ends here


