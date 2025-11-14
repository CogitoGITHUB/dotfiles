;; evil.el --- Live-Shaping Evil module -*- lexical-binding: t; -*-
;;; Commentary:
;; Evil + Evil Collection + Annalist dependency for the Live-Shaping system.

;;; Code:

(defvar live-shaping-dir
  (expand-file-name "Live-Shaping" user-emacs-directory)
  "Root directory for Live-Shaping modules and sources.")

(defun live-shaping--src (folder)
  "Return full path to a vendor source FOLDER inside Live-Shaping/sources."
  (expand-file-name
   (concat "sources/" folder)
   live-shaping-dir))

;; ---------------------------------------------------------
;; Annalist (required for Evil Collection)
;; ---------------------------------------------------------
(condition-case nil
    (add-to-list 'load-path (live-shaping--src "annalist"))
  (error (message "⚠ Live-Shaping: annalist directory missing")))

(condition-case nil
    (require 'annalist)
  (error (message "⚠ Live-Shaping: Annalist not found — Evil Collection may not work")))


;; ---------------------------------------------------------
;; Evil core
;; ---------------------------------------------------------
(use-package evil
  :load-path (lambda ()
               (list (live-shaping--src "evil")))
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1))

;; ---------------------------------------------------------
;; Evil Collection
;; ---------------------------------------------------------
(use-package evil-collection
  :after evil
  :load-path (lambda ()
               (list (live-shaping--src "evil-collection")))
  :config
  (evil-collection-init))


;; ---------------------------------------------------------
;; Dired adjustments (classic and safe)
;; ---------------------------------------------------------
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") 'dired-find-file
    (kbd "^")   'dired-up-directory))

(provide 'evil)
;;; evil.el ends here
