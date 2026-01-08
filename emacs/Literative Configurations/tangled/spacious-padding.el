;;; -*- lexical-binding: t -*-

;; Width of the echo area display
(setq tab-bar-echo-area-width 30)

;; What to show in the echo area
(setq tab-bar-echo-area-format
'(" "
tab-bar-echo-area-current-tab-index
"/"
tab-bar-echo-area-tab-count
" · "
tab-bar-echo-area-buffer-name))

(require 'tab-bar-echo-area)

;; This mode installs all necessary hooks internally
(tab-bar-echo-area-mode 1)

(custom-set-faces
'(tab-bar-echo-area
((t (:inherit shadow)))))
