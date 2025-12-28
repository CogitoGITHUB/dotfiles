;;; -*- lexical-binding: t -*-

(leaf tab-bar-echo-area
  :straight (tab-bar-echo-area :type git :host github :repo "protesilaos/tab-bar-echo-area")
  :config
  (condition-case err
      (progn (require 'tab-bar-echo-area) (tab-bar-echo-area-mode 1))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/tab-bar-echo-area.org"
  		      :line 8 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/tab-bar-echo-area.org"
  			      8 (error-message-string err))
  		      :error)))))

