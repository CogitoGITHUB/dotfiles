;;; -*- lexical-binding: t -*-

(leaf dashboard
  :straight t
  :init
  (condition-case err
      (progn
        (setq dashboard-startup-banner 'official
  	    dashboard-center-content t dashboard-show-shortcuts t
  	    dashboard-set-navigator t dashboard-set-init-info t
  	    dashboard-items
  	    '((recents . 5) (bookmarks . 5) (projects . 5)
  	      (agenda . 5))
  	    dashboard-week-agenda t
  	    dashboard-display-agenda-at-startup t
  	    dashboard-filter-agenda-entry 'dashboard-no-filter-agenda
  	    dashboard-banner-logo-title
  	    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n       SHAPESHIFTER — THE DVORAK BLADE\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  	    dashboard-footer-messages
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
  		      :line 8 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      8 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq dashboard-navigator-buttons
  	    `
  	    ((("g" "GitHub" "Open GitHub [g]"
  	       (lambda (&rest _) (browse-url "https://github.com")))
  	      ("i" "Config" "Open init file [i]"
  	       (lambda (&rest _) (find-file user-init-file)))
  	      ("d" "Docs" "Open documentation [d]"
  	       (lambda (&rest _)
  		 (browse-url
  		  "https://www.gnu.org/software/emacs/manual/")))
  	      ("u" "Update" "Update packages [u]"
  	       (lambda (&rest _) (straight-pull-all)))
  	      ("f" "Dired" "Open file manager [f]"
  	       (lambda (&rest _) (dired "~")))
  	      ("c" "Calendar" "Open calendar [c]"
  	       (lambda (&rest _) (calendar)))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 37 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      37 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (require 'dashboard) (dashboard-setup-startup-hook)
        (add-hook 'dashboard-mode-hook
  		(lambda nil (setq-local cursor-type nil)
  		  (hl-line-mode 1)))
        (setq initial-buffer-choice
  	    (lambda nil (get-buffer-create dashboard-buffer-name))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 55 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      55 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dashboard-refresh nil
  	"Refresh the dashboard buffer." (interactive)
  	(when (get-buffer dashboard-buffer-name)
  	  (kill-buffer dashboard-buffer-name))
  	(dashboard-insert-startupify-lists)
  	(switch-to-buffer dashboard-buffer-name) (dashboard-mode))
        (defun shapeshifter/dashboard-goto-section (section)
  	"Jump to a SECTION in dashboard." (interactive "sSection: ")
  	(with-current-buffer dashboard-buffer-name
  	  (goto-char (point-min)) (search-forward section nil t)
  	  (forward-line 1)))
        (defun shapeshifter/dashboard-goto-recent-files nil
  	"Jump to recent files section." (interactive)
  	(shapeshifter/dashboard-goto-section "Recent Files:"))
        (defun shapeshifter/dashboard-goto-projects nil
  	"Jump to projects section." (interactive)
  	(shapeshifter/dashboard-goto-section "Projects:"))
        (defun shapeshifter/dashboard-goto-bookmarks nil
  	"Jump to bookmarks section." (interactive)
  	(shapeshifter/dashboard-goto-section "Bookmarks:")))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 70 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      70 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'dashboard
  	(define-key dashboard-mode-map "h" 'widget-backward)
  	(define-key dashboard-mode-map "t" 'next-line)
  	(define-key dashboard-mode-map "n" 'previous-line)
  	(define-key dashboard-mode-map "s" 'widget-forward)
  	(define-key dashboard-mode-map "H" 'dashboard-previous-section)
  	(define-key dashboard-mode-map "S" 'dashboard-next-section)
  	(define-key dashboard-mode-map (kbd "RET")
  		    'widget-button-press)
  	(define-key dashboard-mode-map (kbd "SPC")
  		    'widget-button-press)
  	(define-key dashboard-mode-map (kbd "TAB") 'widget-forward)
  	(define-key dashboard-mode-map (kbd "S-TAB") 'widget-backward)
  	(define-key dashboard-mode-map "g"
  		    (lambda nil (interactive)
  		      (browse-url "https://github.com")))
  	(define-key dashboard-mode-map "i"
  		    (lambda nil (interactive)
  		      (find-file user-init-file)))
  	(define-key dashboard-mode-map "d"
  		    (lambda nil (interactive)
  		      (browse-url
  		       "https://www.gnu.org/software/emacs/manual/")))
  	(define-key dashboard-mode-map "u"
  		    (lambda nil (interactive) (straight-pull-all)))
  	(define-key dashboard-mode-map "f"
  		    (lambda nil (interactive) (dired "~")))
  	(define-key dashboard-mode-map "c" 'calendar)
  	(define-key dashboard-mode-map "r"
  		    'shapeshifter/dashboard-refresh)
  	(define-key dashboard-mode-map "q" 'quit-window)
  	(define-key dashboard-mode-map "Q" 'kill-buffer-and-window))
        (with-eval-after-load 'evil
  	(evil-set-initial-state 'dashboard-mode 'emacs)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 105 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      105 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defface shapeshifter-dashboard-banner-face
  	'((t :foreground "white" :weight bold))
  	"Face for dashboard banner." :group 'dashboard)
        (with-eval-after-load 'dashboard
  	(set-face-attribute 'dashboard-heading nil :foreground "white"
  			    :weight 'bold)
  	(set-face-attribute 'dashboard-items-face nil :foreground
  			    "gray70")
  	(set-face-attribute 'dashboard-no-items-face nil :foreground
  			    "gray50")
  	(set-face-attribute 'dashboard-text-banner nil :foreground
  			    "white" :weight 'bold)
  	(set-face-attribute 'dashboard-banner-logo-title nil
  			    :foreground "white" :weight 'bold)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 143 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      143 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq recentf-max-saved-items 50 recentf-max-menu-items 15
  	    recentf-exclude
  	    '("/tmp/" "/ssh:" "/sudo:" "\\.git/" "COMMIT_EDITMSG"
  	      ".*\\.elc$"))
        (run-at-time nil (* 5 60) 'recentf-save-list)
        (setq bookmark-default-file
  	    (expand-file-name "bookmarks" user-emacs-directory)
  	    bookmark-save-flag 1))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 167 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      167 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'projectile
  	(setq dashboard-projects-backend 'projectile)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  		      :line 178 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dashboard.org"
  			      178 (error-message-string err))
  		      :error)))))

