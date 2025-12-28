;;; -*- lexical-binding: t -*-

(leaf tab-bar-echo-area
  :straight (tab-bar-echo-area :type git :host github :repo "protesilaos/tab-bar-echo-area")
  :init
  (condition-case err
      (progn
        (setq tab-bar-echo-area-width 30)
        (setq tab-bar-echo-area-format
  	    '(" " tab-bar-echo-area-current-tab-index "/"
  	      tab-bar-echo-area-tab-count " · "
  	      tab-bar-echo-area-buffer-name)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  		      :line 8 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  			      8 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn (require 'tab-bar-echo-area) (tab-bar-echo-area-mode 1))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  		      :line 23 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  			      23 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (custom-set-faces '(tab-bar-echo-area ((t (:inherit shadow))))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  		      :line 31 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/spacious-padding.org"
  			      31 (error-message-string err))
  		      :error)))))

