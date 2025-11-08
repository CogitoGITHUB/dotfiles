;;; evil.el --- Evil mode configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Manual source + use-package hybrid setup.

;;; Code:

(use-package evil
  :load-path "sources/evil"
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1))

(provide 'evil)
;;; evil.el ends here
