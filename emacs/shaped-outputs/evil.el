;;; -*- lexical-binding: t -*-

(leaf evil
  :straight (evil :type git :host github :repo "emacs-evil/evil")
  :init
  (condition-case err
      (progn (setq evil-want-keybinding nil evil-want-C-u-scroll t))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 7 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      7 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err (progn (evil-mode 1))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 12 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      12 (error-message-string err))
  		      :error))))
  
  (condition-case err nil
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 16 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      16 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshifter-leader-map (make-sparse-keymap))
        (define-key evil-normal-state-map (kbd "SPC")
  		  shapeshifter-leader-map)
        (define-key evil-motion-state-map (kbd "SPC")
  		  shapeshifter-leader-map))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 40 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      40 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (define-key shapeshifter-leader-map (kbd "f") #'find-file)
        (define-key shapeshifter-leader-map (kbd "s") #'save-buffer)
        (define-key shapeshifter-leader-map (kbd "g") #'magit-status)
        (define-key shapeshifter-leader-map (kbd "b") #'switch-to-buffer)
        (define-key shapeshifter-leader-map (kbd "k") #'kill-buffer)
        (define-key shapeshifter-leader-map (kbd "j")
  		  #'avy-goto-char-timer)
        (define-key shapeshifter-leader-map (kbd "d") #'dired)
        (define-key shapeshifter-leader-map (kbd "D") #'dired-jump)
        (define-key shapeshifter-leader-map (kbd "w")
  		  (make-sparse-keymap))
        (define-key shapeshifter-leader-map (kbd "wh")
  		  #'evil-window-left)
        (define-key shapeshifter-leader-map (kbd "ws")
  		  #'evil-window-right)
        (define-key shapeshifter-leader-map (kbd "wt")
  		  #'evil-window-down)
        (define-key shapeshifter-leader-map (kbd "wn") #'evil-window-up)
        (define-key shapeshifter-leader-map (kbd "ww")
  		  #'evil-window-next)
        (define-key shapeshifter-leader-map (kbd "wv")
  		  #'evil-window-vsplit)
        (define-key shapeshifter-leader-map (kbd "wx")
  		  #'evil-window-split)
        (define-key shapeshifter-leader-map (kbd "wq")
  		  #'evil-window-delete))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 49 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      49 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'org
  	(evil-define-key 'normal org-mode-map
  	  (kbd "TAB") #'org-cycle (kbd "<tab>") #'org-cycle
  	  (kbd "<C-tab>") #'org-shifttab (kbd "C-<tab>")
  	  #'org-shifttab)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 75 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      75 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/open-grease-here nil
  	"Open Grease directly in the current buffer's directory."
  	(interactive) (grease-open default-directory))
        (defun shapeshifter/open-grease-prompt nil
  	"Prompt for a directory (default to current buffer) and open Grease there."
  	(interactive)
  	(let
  	    ((dir
  	      (read-directory-name "Open Grease in directory: "
  				   default-directory)))
  	  (grease-open dir)))
        (define-key shapeshifter-leader-map (kbd "x")
  		  #'shapeshifter/open-grease-here)
        (define-key shapeshifter-leader-map (kbd "X")
  		  #'shapeshifter/open-grease-prompt))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 87 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      87 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'grease
  	(evil-define-key 'normal grease-mode-map
  	  (kbd "h") #'grease-up-directory (kbd "s") #'grease-visit
  	  (kbd "t") #'evil-next-line (kbd "n") #'evil-previous-line
  	  (kbd "RET") #'grease-visit (kbd ".") #'grease-toggle-hidden
  	  (kbd "<left>") #'grease-up-directory (kbd "<right>")
  	  #'grease-visit (kbd "<up>") #'evil-previous-line
  	  (kbd "<down>") #'evil-next-line)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 112 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      112 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'tab-bar-echo-area
  	(define-key shapeshifter-leader-map (kbd "t")
  		    (make-sparse-keymap))
  	(define-key shapeshifter-leader-map (kbd "tc")
  		    #'tab-bar-echo-area-print-tab-name)
  	(define-key shapeshifter-leader-map (kbd "tp")
  		    #'tab-bar-echo-area-print-tab-names)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 147 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      147 (error-message-string err))
  		      :error)))))

(leaf annalist
  :straight (annalist :type git :host github :repo "noctuid/annalist.el"))

(leaf evil-collection
  :straight (evil-collection :type git :host github :repo "emacs-evil/evil-collection")
  :after (evil annalist)
  :config
  (condition-case err (progn (evil-collection-init))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 175 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      175 (error-message-string err))
  		      :error)))))

(leaf evil-surround
  :straight (evil-surround :type git :host github :repo "timcharper/evil-surround")
  :after evil
  :config
  (condition-case err (progn (global-evil-surround-mode 1))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 185 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      185 (error-message-string err))
  		      :error)))))

(leaf multiple-cursors
  :straight t
  :after evil)

(leaf evil-nerd-commenter
  :straight (evil-nerd-commenter :type git :host github :repo "redguardtoo/evil-nerd-commenter")
  :after evil
  :config
  (condition-case err
      (progn
        (declare-function web-mode-comment-or-uncomment-region
  			"web-mode")
        (setq evilnc-comment-text-object "c") (evilnc-default-hotkeys)
        (define-key evil-normal-state-map (kbd "gc")
  		  #'evilnc-comment-or-uncomment-lines)
        (define-key evil-visual-state-map (kbd "gc")
  		  #'evilnc-comment-or-uncomment-lines)
        (define-key evil-normal-state-map (kbd "gC")
  		  #'evilnc-copy-and-comment-lines))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  		      :line 201 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/evil.org"
  			      201 (error-message-string err))
  		      :error)))))

