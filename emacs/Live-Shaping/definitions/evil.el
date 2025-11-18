;; evil.el --- Live-Shaping Evil module -*- lexical-binding: t; -*-
;;; Commentary:
;; Evil + Evil Collection + Dvorak HTNS navigation.

;;; Code:

;; ---------------------------------------------------------
;; Define Live-Shaping directory utilities FIRST
;; ---------------------------------------------------------

(defvar live-shaping-dir
  (expand-file-name "Live-Shaping" user-emacs-directory)
  "Root directory for the Live-Shaping environment.")

(defun live-shaping--src (name)
  "Return full path to NAME inside Live-Shaping/sources/."
  (expand-file-name
   (concat "sources/" name)
   live-shaping-dir))

;; ---------------------------------------------------------
;; Annalist (required by Evil Collection)
;; ---------------------------------------------------------

(add-to-list 'load-path (live-shaping--src "annalist"))
(condition-case nil
    (require 'annalist)
  (error
   (message "⚠ Live-Shaping: Annalist missing; Evil Collection may misbehave.")))

;; ---------------------------------------------------------
;; Evil Core
;; ---------------------------------------------------------

(use-package evil
  :load-path (lambda () (list (live-shaping--src "evil")))
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1)

  ;; Dvorak HTNS movement (physical diamond)
  (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)  ;; left
  (define-key evil-normal-state-map (kbd "t") 'evil-next-line)      ;; down
  (define-key evil-normal-state-map (kbd "n") 'evil-previous-line)  ;; up
  (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)   ;; right

  (define-key evil-visual-state-map (kbd "h") 'evil-backward-char)
  (define-key evil-visual-state-map (kbd "t") 'evil-next-line)
  (define-key evil-visual-state-map (kbd "n") 'evil-previous-line)
  (define-key evil-visual-state-map (kbd "s") 'evil-forward-char))

;; ---------------------------------------------------------
;; Evil Collection
;; ---------------------------------------------------------

(use-package evil-collection
  :after evil
  :load-path (lambda () (list (live-shaping--src "evil-collection")))
  :config
  (evil-collection-init))

;; ---------------------------------------------------------
;; Dired Fixes
;; ---------------------------------------------------------

(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") 'dired-find-file
    (kbd "^")   'dired-up-directory))

(provide 'evil)
;;; evil.el ends here
