;;; -*- lexical-binding: t -*-

(leaf evil
  :straight (evil :type git :host github :repo "emacs-evil/evil")
  :init
  (condition-case err
      (progn (setq evil-want-keybinding nil evil-want-C-u-scroll t))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 8 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      8 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err (progn (evil-mode 1))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 14 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      14 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (define-key evil-normal-state-map (kbd "h") 'evil-backward-char)
        (define-key evil-normal-state-map (kbd "t") 'evil-next-line)
        (define-key evil-normal-state-map (kbd "n") 'evil-previous-line)
        (define-key evil-normal-state-map (kbd "s") 'evil-forward-char)
        (define-key evil-motion-state-map (kbd "h") 'evil-backward-char)
        (define-key evil-motion-state-map (kbd "t") 'evil-next-line)
        (define-key evil-motion-state-map (kbd "n") 'evil-previous-line)
        (define-key evil-motion-state-map (kbd "s") 'evil-forward-char))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 19 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      19 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshifter-leader-map (make-sparse-keymap))
        (define-key evil-normal-state-map (kbd "SPC")
  		  shapeshifter-leader-map)
        (define-key evil-motion-state-map (kbd "SPC")
  		  shapeshifter-leader-map))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 32 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      32 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (define-key shapeshifter-leader-map (kbd "f") #'find-file)
        (define-key shapeshifter-leader-map (kbd "s") #'save-buffer)
        (define-key shapeshifter-leader-map (kbd "g") #'magit-status)
        (define-key shapeshifter-leader-map (kbd "b") #'switch-to-buffer)
        (define-key shapeshifter-leader-map (kbd "k") #'kill-buffer)
        (define-key shapeshifter-leader-map (kbd "j")
  		  #'avy-goto-char-timer))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 40 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      40 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'dired
  	(evil-define-key 'normal dired-mode-map
  	  (kbd "RET") #'dired-find-file (kbd "TAB") #'revert-buffer)))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 51 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      51 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'org
  	(evil-define-key 'normal org-mode-map
  	  (kbd "TAB") #'org-cycle (kbd "<C-tab>") #'org-shifttab)))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 60 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      60 (error-message-string err))
  		      :error)))))

(leaf annalist
  :straight (annalist :type git :host github :repo "noctuid/annalist.el"))

(leaf evil-collection
  :straight (evil-collection :type git :host github :repo "emacs-evil/evil-collection")
  :after (evil annalist)
  :config
  (condition-case err (progn (evil-collection-init))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 82 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      82 (error-message-string err))
  		      :error)))))

(leaf evil-surround
  :straight (evil-surround :type git :host github :repo "timcharper/evil-surround")
  :after evil
  :config
  (condition-case err (progn (global-evil-surround-mode 1))
    (error
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 94 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      94 (error-message-string err))
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
     (add-to-list 'tree--boot-errors
  		(list :file "/home/asdf/.config/emacs/org/evil.org"
  		      :line 113 :message (error-message-string err)))
     (unless tree--booting
       (display-warning 'tree
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/org/evil.org"
  			      113 (error-message-string err))
  		      :error)))))

