;;; ~/.emacs.d/early-init.el
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)

;; Kill modeline and header entirely
(setq-default mode-line-format nil)
(setq-default header-line-format nil)

;; No fringe — full-bleed text
(set-fringe-mode 0)

;; Frame purity
(setq default-frame-alist
      '((undecorated . t)
        (internal-border-width . 0)
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)))
(window-divider-mode -1)
