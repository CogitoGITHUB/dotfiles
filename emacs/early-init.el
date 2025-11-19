(setq package-enable-at-startup nil)

;; ---- No UI ----
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

;; ---- faster startup ----
(setq package-enable-at-startup nil)
(setq frame-inhibit-implied-resize t)
(setq inhibit-startup-message t)

;; ---- minimalist frame ----
(setq default-frame-alist
      '((vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (undecorated . t)
        (fullscreen . nil)))  ;; or 'maximized


(global-visual-line-mode t)
