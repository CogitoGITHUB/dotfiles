;;; -*- lexical-binding: t -*-

(setq org-superstar-headline-bullets-list '("Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ")
      org-superstar-remove-leading-stars t
      org-superstar-leading-fallback ?\s
      org-hide-leading-stars t)

(require 'org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

;; Ensure it activates for existing org buffers after load
(with-eval-after-load 'org-superstar
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
        (org-superstar-mode 1)))))

(custom-set-faces
 '(org-superstar-header-bullet ((t (:foreground "#000000" :weight bold :height 1.1))))
 '(org-superstar-item ((t (:foreground "#000000"))))
 '(org-superstar-leading ((t (:foreground "#000000"))))
 '(org-hide ((t (:foreground "white" :background "white")))))

;; Force hide leading stars
(with-eval-after-load 'org
  (set-face-attribute 'org-hide nil :foreground (face-background 'default)))
