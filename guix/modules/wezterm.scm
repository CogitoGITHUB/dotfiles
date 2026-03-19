;; Wezterm terminal emulator - just use the one from guix
(use-modules (gnu packages terminals))
(define-public wezterm (@ (gnu packages terminals) wezterm))
