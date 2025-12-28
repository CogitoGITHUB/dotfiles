;;; -*- lexical-binding: t -*-

(leaf org-superstar
  :straight (org-superstar :type git :host github :repo "integral-dw/org-superstar-mode")
  :after org
  :init
  (condition-case err
      (progn
        (setq org-superstar-headline-bullets-list
  	    '("Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ")
  	    org-superstar-remove-leading-stars t
  	    org-superstar-leading-fallback 32 org-hide-leading-stars t))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  		      :line 9 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  			      9 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (require 'org-superstar)
        (add-hook 'org-mode-hook (lambda nil (org-superstar-mode 1)))
        (with-eval-after-load 'org-superstar
  	(dolist (buffer (buffer-list))
  	  (with-current-buffer buffer
  	    (when (derived-mode-p 'org-mode) (org-superstar-mode 1))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  		      :line 17 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  			      17 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (custom-set-faces
         '(org-superstar-header-bullet
  	 ((t (:foreground "#000000" :weight bold :height 1.1))))
         '(org-superstar-item ((t (:foreground "#000000"))))
         '(org-superstar-leading ((t (:foreground "#000000"))))
         '(org-hide ((t (:foreground "white" :background "white")))))
        (with-eval-after-load 'org
  	(set-face-attribute 'org-hide nil :foreground
  			    (face-background 'default))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  		      :line 30 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/org-superstar.org"
  			      30 (error-message-string err))
  		      :error)))))

