;; Wezterm terminal emulator - just use the one from guix
(define-module (wezterm)
  #:use-module (gnu packages terminals))

(use-modules (gnu packages terminals))
(define-public wezterm wezterm)
