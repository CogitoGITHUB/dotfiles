;;; evil.el --- Evil mode configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Manual source + use-package hybrid setup with Evil Collection and Annalist.

;;; Code:

;; --- Annalist dependency (required by Evil Collection) ---
(add-to-list 'load-path (expand-file-name "sources/annalist" user-emacs-directory))
(condition-case nil
    (require 'annalist)
  (error (message "⚠️ Annalist not found — please clone it as submodule: \
git submodule add https://github.com/noctuid/annalist.el.git emacs/sources/annalist")))

;; --- Evil core ---
(use-package evil
  :load-path "sources/evil"
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1))

;; --- Evil Collection ---
(use-package evil-collection
  :after evil
  :load-path "sources/evil-collection"
  :config
  (evil-collection-init))

;; --- Extra: explicit Dired key fix (safe even with Evil Collection) ---
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") 'dired-find-file
    (kbd "^") 'dired-up-directory))

(provide 'evil)
;;; evil.el ends here
