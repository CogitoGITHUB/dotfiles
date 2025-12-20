;;; -*- lexical-binding: t -*-

(leaf dashboard
  :straight t
  :init
  (condition-case err
      (progn
        (setq dashboard-startup-banner 'logo dashboard-center-content t
  	    dashboard-show-shortcuts t dashboard-set-heading-icons t
  	    dashboard-set-file-icons t dashboard-set-navigator t
  	    dashboard-set-init-info t))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 8 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      8 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-items
  	    '((recents . 5) (bookmarks . 5) (projects . 5)
  	      (agenda . 5))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 22 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      22 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-banner-logo-title
  	    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n         SHAPESHIFTER — THE DVORAK BLADE\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 33 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      33 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-footer-messages
  	    '("The blade that adapts, survives."
  	      "Every keystroke is a choice."
  	      "HTNS — The path of efficiency."
  	      "Shape your tools, shape your mind."
  	      "In simplicity, power emerges."
  	      "The editor is a canvas of thought."
  	      "Precision over speed, always."
  	      "Master the fundamentals, transcend the rest.")))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 44 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      44 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-navigator-buttons
  	    `
  	    (((,(when (display-graphic-p)
  		  (all-the-icons-octicon "mark-github" :height 1.1
  					 :v-adjust 0.0))
  	       "GitHub" "Open GitHub"
  	       (lambda (&rest _) (browse-url "https://github.com")))
  	      (,(when (display-graphic-p)
  		  (all-the-icons-faicon "cog" :height 1.1 :v-adjust
  					0.0))
  	       "Config" "Open init file"
  	       (lambda (&rest _) (find-file user-init-file)))
  	      (,(when (display-graphic-p)
  		  (all-the-icons-octicon "book" :height 1.1 :v-adjust
  					 0.0))
  	       "Docs" "Open documentation"
  	       (lambda (&rest _)
  		 (browse-url
  		  "https://www.gnu.org/software/emacs/manual/")))
  	      (,(when (display-graphic-p)
  		  (all-the-icons-material "update" :height 1.1
  					  :v-adjust 0.0))
  	       "Update" "Update packages"
  	       (lambda (&rest _) (straight-pull-all)))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 60 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      60 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn (require 'dashboard) (dashboard-setup-startup-hook))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 92 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      92 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dashboard-refresh nil
  	"Refresh the dashboard buffer." (interactive)
  	(when (get-buffer dashboard-buffer-name)
  	  (kill-buffer dashboard-buffer-name))
  	(dashboard-insert-startupify-lists)
  	(switch-to-buffer dashboard-buffer-name) (dashboard-mode))
        (defun shapeshifter/dashboard-goto-recent-files nil
  	"Jump to recent files section." (interactive)
  	(with-current-buffer dashboard-buffer-name
  	  (goto-char (point-min))
  	  (search-forward "Recent Files:" nil t) (forward-line 1)))
        (defun shapeshifter/dashboard-goto-projects nil
  	"Jump to projects section." (interactive)
  	(with-current-buffer dashboard-buffer-name
  	  (goto-char (point-min)) (search-forward "Projects:" nil t)
  	  (forward-line 1)))
        (defun shapeshifter/dashboard-goto-bookmarks nil
  	"Jump to bookmarks section." (interactive)
  	(with-current-buffer dashboard-buffer-name
  	  (goto-char (point-min)) (search-forward "Bookmarks:" nil t)
  	  (forward-line 1))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 98 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      98 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (add-hook 'dashboard-mode-hook
  		(lambda nil (setq-local cursor-type nil)
  		  (hl-line-mode 1)))
        (setq initial-buffer-choice
  	    (lambda nil (get-buffer-create dashboard-buffer-name))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 137 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      137 (error-message-string err))
  		      :error))))
  
  (condition-case err nil
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 151 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      151 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'evil
  	(evil-define-key 'normal dashboard-mode-map
  	  (kbd "t") 'dashboard-next-line (kbd "n")
  	  'dashboard-previous-line (kbd "h")
  	  'dashboard-previous-section (kbd "s")
  	  'dashboard-next-section (kbd "RET") 'widget-button-press
  	  (kbd "SPC") 'widget-button-press (kbd "TAB") 'widget-forward
  	  (kbd "<tab>") 'widget-forward (kbd "S-TAB") 'widget-backward
  	  (kbd "gr") 'shapeshifter/dashboard-goto-recent-files
  	  (kbd "gp") 'shapeshifter/dashboard-goto-projects (kbd "gb")
  	  'shapeshifter/dashboard-goto-bookmarks (kbd "gg")
  	  'evil-goto-first-line (kbd "G") 'evil-goto-line (kbd "r")
  	  'shapeshifter/dashboard-refresh (kbd "q") 'quit-window
  	  (kbd "Q") 'kill-buffer-and-window)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 174 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      174 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defface shapeshifter-dashboard-banner-face
  	'((t :inherit font-lock-keyword-face :weight bold))
  	"Face for dashboard banner." :group 'dashboard)
        (with-eval-after-load 'dashboard
  	(set-face-attribute 'dashboard-heading nil :foreground
  			    "#61AFEF" :weight 'bold)
  	(set-face-attribute 'dashboard-items-face nil :foreground
  			    "#ABB2BF")))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 215 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      215 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq recentf-max-saved-items 50 recentf-max-menu-items 15
  	    recentf-exclude
  	    '("/tmp/" "/ssh:" "/sudo:" "\\.git/" "COMMIT_EDITMSG"
  	      ".*\\.elc$"))
        (run-at-time nil (* 5 60) 'recentf-save-list))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 235 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      235 (error-message-string err))
  		      :error))))
  
  (condition-case err nil
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 253 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      253 (error-message-string err))
  		      :error))))
  
  (condition-case err nil
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 266 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      266 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-startupify-list
  	    '(dashboard-insert-banner dashboard-insert-newline
  				      dashboard-insert-banner-title
  				      dashboard-insert-newline
  				      dashboard-insert-navigator
  				      dashboard-insert-newline
  				      dashboard-insert-init-info
  				      dashboard-insert-items))
        (add-hook 'after-make-frame-functions
  		(lambda (frame)
  		  (with-selected-frame frame
  		    (dashboard-refresh-buffer)))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 275 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      275 (error-message-string err))
  		      :error)))))

