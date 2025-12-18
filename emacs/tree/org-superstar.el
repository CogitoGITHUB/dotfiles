;;; -*- lexical-binding: t -*-

(leaf org-superstar
  :straight (org-superstar :type git :host github :repo "integral-dw/org-superstar-mode")
  :after org
  :hook
  (org-mode . org-superstar-mode)
  :custom
  (org-superstar-headline-bullets-list . '(?Ⅰ ?Ⅱ ?Ⅲ ?Ⅳ ?Ⅴ ?Ⅵ ?Ⅶ ?Ⅷ))
(org-superstar-remove-leading-stars . t)
(org-superstar-leading-fallback . ?\s)
  :config
  (condition-case err
      (progn
        (custom-set-faces
         '(org-superstar-header-bullet
  	 ((t (:foreground "#000000" :weight bold :height 1.1))))
         '(org-superstar-item ((t (:foreground "#000000"))))
         '(org-superstar-leading ((t (:foreground "#000000"))))))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/org/org-superstar.org"
  		      :line 21 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/org-superstar.org"
  			      21 (error-message-string err))
  		      :error)))))

