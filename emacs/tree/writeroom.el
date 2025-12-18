;;; -*- lexical-binding: t -*-

(leaf writeroom-mode
  :straight (writeroom-mode :type git :host github :repo "joostkremers/writeroom-mode")
  :after visual-fill-column
  :config
  (condition-case err (progn (global-writeroom-mode 1))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/org/writeroom.org"
  		      :line 9 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/writeroom.org"
  			      9 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq writeroom-global-effects nil writeroom-maximize-window nil
  	    writeroom-mode-line nil writeroom-bottom-divider-width 0))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/org/writeroom.org"
  		      :line 14 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/writeroom.org"
  			      14 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'writeroom-mode
  	(define-key writeroom-mode-map (kbd "C-<")
  		    #'writeroom-decrease-width)
  	(define-key writeroom-mode-map (kbd "C->")
  		    #'writeroom-increase-width)
  	(define-key writeroom-mode-map (kbd "C-=")
  		    #'writeroom-adjust-width)))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/org/writeroom.org"
  		      :line 23 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/writeroom.org"
  			      23 (error-message-string err))
  		      :error)))))

