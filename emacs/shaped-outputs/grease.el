;;; -*- lexical-binding: t -*-

(leaf grease
  :straight (grease :type git :host github :repo "mwac-dev/grease.el")
  :config
  (condition-case err nil
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/grease.org"
  		      :line 8 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/grease.org"
  			      8 (error-message-string err))
  		      :error)))))

