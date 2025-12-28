;;; -*- lexical-binding: t -*-

(leaf org-roam-ui
  :straight (org-roam-ui :type git :host github :repo "org-roam/org-roam-ui" :files ("*.el" "out"))
  :after org-roam
  :init
  (condition-case err
      (progn
        (setq org-roam-ui-sync-theme t org-roam-ui-follow t
              org-roam-ui-update-on-save t))
    (error
     (add-to-list 'shaping--boot-errors
                  (list :file
                        "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                        :line 9 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
                        (format "Error loading %s:%s - %s"
                                "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                                9 (error-message-string err))
                        :error))))
  
  :config
  (condition-case err nil
    (error
     (add-to-list 'shaping--boot-errors
                  (list :file
                        "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                        :line 18 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
                        (format "Error loading %s:%s - %s"
                                "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                                18 (error-message-string err))
                        :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/org-roam-ui-sync-theme (&rest _)
          "Sync org-roam-ui with monochrome theme."
          (when
              (and (featurep 'org-roam-ui)
                   (bound-and-true-p org-roam-ui-mode))
            (org-roam-ui--update-theme))))
    (error
     (add-to-list 'shaping--boot-errors
                  (list :file
                        "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                        :line 24 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
                        (format "Error loading %s:%s - %s"
                                "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                                24 (error-message-string err))
                        :error))))
  
  (condition-case err
      (progn
        (advice-add 'load-theme :after
                    #'shapeshifter/org-roam-ui-sync-theme)
        (advice-add 'shapeshift/monochrome-world :after
                    #'shapeshifter/org-roam-ui-sync-theme))
    (error
     (add-to-list 'shaping--boot-errors
                  (list :file
                        "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                        :line 33 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
                        (format "Error loading %s:%s - %s"
                                "/home/asdf/.config/emacs/shaping-packages/org-roam-ui.org"
                                33 (error-message-string err))
                        :error)))))

