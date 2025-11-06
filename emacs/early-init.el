;; Performance tweaks
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ; 1MB

;; UI cleanup
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 0)
(setq inhibit-startup-screen t)

;; Line numbers globally
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
