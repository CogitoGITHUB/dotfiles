;; ~/.emacs.d/init.el
;; -*- lexical-binding: t; -*-

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

;; === straight.el integration ===
(setq straight-use-package-by-default t)
(straight-use-package 'use-package)
(require 'use-package)

;; === UI tweaks ===
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t
      ring-bell-function 'ignore)

;; === Performance ===
(setq read-process-output-max (* 1024 1024)
      gc-cons-threshold (* 100 1024 1024)
      gc-cons-percentage 0.6)



(global-font-lock-mode -1)
(setq font-lock-maximum-decoration nil)

;; Disable all themes
(mapc #'disable-theme custom-enabled-themes)
(setq custom-safe-themes t)

;; Make all faces use default face (monochrome)
(defun disable-all-face-colors ()
  (mapatoms
   (lambda (sym)
     (when (facep sym)
       (set-face-attribute sym nil
                           :foreground nil
                           :background nil
                           :underline nil
                           :box nil
                           :weight 'normal
                           :slant 'normal)))))
(disable-all-face-colors)

;; Disable ANSI color in shell, eshell, and compilation buffers
(setq ansi-color-for-comint-mode nil)
(setq ansi-color-names-vector [default default default default default default default default])
(advice-add 'ansi-color-apply :override #'identity)

(setq custom-file (make-temp-file "emacs-custom"))


(setq-default header-line-format
              '((:eval
                 (let* ((name (buffer-name))
                        (width (window-total-width))
                        (padding (/ (- width (length name)) 2)))
                   (concat (make-string (max 0 padding) ? ) name)))))




(global-visual-line-mode 1)
