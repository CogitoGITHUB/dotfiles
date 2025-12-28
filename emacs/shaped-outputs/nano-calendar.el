;;; -*- lexical-binding: t -*-

(leaf nano-calendar
  :straight (nano-calendar :type git :host github :repo "rougier/nano-calendar")
  :init
  (condition-case err
      (progn
        (setq calendar-week-start-day 1 calendar-date-style 'iso
  	    calendar-mark-holidays-flag t
  	    calendar-mark-diary-entries-flag t
  	    calendar-view-diary-initially-flag nil
  	    calendar-view-holidays-initially-flag nil))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 8 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      8 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (when (fboundp 'native-comp-available-p)
  	(when (native-comp-available-p)
  	  (setq native-comp-async-report-warnings-errors nil)))
        (require 'nano-calendar)
        (add-hook 'calendar-initial-window-hook
  		(lambda nil (calendar-goto-today))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 18 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      18 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/calendar-open nil
  	"Open nano-calendar centered on today." (interactive)
  	(calendar) (calendar-goto-today))
        (defun shapeshifter/calendar-goto-date nil
  	"Jump to a specific date in calendar." (interactive)
  	(let*
  	    ((date (org-read-date nil t))
  	     (month (string-to-number (format-time-string "%m" date)))
  	     (day (string-to-number (format-time-string "%d" date)))
  	     (year (string-to-number (format-time-string "%Y" date))))
  	  (calendar-goto-date (list month day year))))
        (defun shapeshifter/calendar-add-event nil
  	"Add an event to org-agenda from calendar." (interactive)
  	(let*
  	    ((date (calendar-cursor-to-date))
  	     (time-string
  	      (format "%04d-%02d-%02d" (nth 2 date) (nth 0 date)
  		      (nth 1 date))))
  	  (org-capture nil "a"))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 33 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      33 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'calendar
  	(define-key calendar-mode-map "h" 'calendar-backward-day)
  	(define-key calendar-mode-map "t" 'calendar-forward-week)
  	(define-key calendar-mode-map "n" 'calendar-backward-week)
  	(define-key calendar-mode-map "s" 'calendar-forward-day)
  	(define-key calendar-mode-map "H" 'calendar-backward-month)
  	(define-key calendar-mode-map "S" 'calendar-forward-month)
  	(define-key calendar-mode-map "T" 'calendar-forward-year)
  	(define-key calendar-mode-map "N" 'calendar-backward-year)
  	(define-key calendar-mode-map "." 'calendar-goto-today)
  	(define-key calendar-mode-map "g"
  		    'shapeshifter/calendar-goto-date)
  	(define-key calendar-mode-map (kbd "RET")
  		    'org-calendar-goto-agenda)
  	(define-key calendar-mode-map (kbd "SPC") 'calendar-set-mark)
  	(define-key calendar-mode-map "a"
  		    'shapeshifter/calendar-add-event)
  	(define-key calendar-mode-map "d" 'diary-view-entries)
  	(define-key calendar-mode-map "m" 'calendar-set-mark)
  	(define-key calendar-mode-map "vh" 'calendar-cursor-holidays)
  	(define-key calendar-mode-map "vd" 'diary-view-entries)
  	(define-key calendar-mode-map "r" 'calendar-redraw)
  	(define-key calendar-mode-map "q" 'calendar-exit)
  	(define-key calendar-mode-map "Q" 'calendar-exit))
        (with-eval-after-load 'evil
  	(evil-set-initial-state 'calendar-mode 'emacs)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 59 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      59 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'calendar
  	(set-face-attribute 'calendar-today nil :background "gray30"
  			    :foreground "white" :weight 'bold)
  	(set-face-attribute 'calendar-weekday-header nil :foreground
  			    "white" :weight 'bold)
  	(set-face-attribute 'calendar-weekend-header nil :foreground
  			    "gray60" :weight 'bold)
  	(set-face-attribute 'calendar-month-header nil :foreground
  			    "white" :weight 'bold :height 1.2)
  	(set-face-attribute 'diary nil :foreground "gray80")
  	(set-face-attribute 'holiday nil :foreground "gray70" :weight
  			    'bold))
        (with-eval-after-load 'nano-calendar
  	(when (facep 'nano-calendar-default)
  	  (set-face-attribute 'nano-calendar-default nil :foreground
  			      "gray70"))
  	(when (facep 'nano-calendar-today)
  	  (set-face-attribute 'nano-calendar-today nil :background
  			      "gray30" :foreground "white" :weight
  			      'bold))
  	(when (facep 'nano-calendar-selected)
  	  (set-face-attribute 'nano-calendar-selected nil :background
  			      "gray20" :foreground "white"))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 99 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      99 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq org-agenda-include-diary t org-agenda-diary-file
  	    (expand-file-name "diary.org" org-directory))
        (add-hook 'calendar-today-visible-hook 'calendar-mark-today)
        (add-hook 'calendar-today-invisible-hook 'calendar-mark-today)
        (defun org-calendar-goto-agenda nil
  	"Show org-agenda for the date under cursor." (interactive)
  	(let*
  	    ((date (calendar-cursor-to-date t))
  	     (date-string
  	      (format "%04d-%02d-%02d" (nth 2 date) (nth 0 date)
  		      (nth 1 date))))
  	  (org-agenda-list nil date-string 'day))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 139 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      139 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq holiday-general-holidays nil holiday-christian-holidays
  	    nil holiday-hebrew-holidays nil holiday-islamic-holidays
  	    nil holiday-bahai-holidays nil holiday-oriental-holidays
  	    nil holiday-solar-holidays nil)
        (setq diary-file (expand-file-name "diary" user-emacs-directory)
  	    diary-display-function 'diary-fancy-display
  	    diary-list-include-blanks nil))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 159 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      159 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (add-to-list 'display-buffer-alist
  		   '("\\*Calendar\\*" (display-buffer-at-bottom)
  		     (window-height . 0.3)))
        (defun shapeshifter/calendar-auto-close nil
  	"Close calendar after selecting a date."
  	(when
  	    (and (eq major-mode 'calendar-mode)
  		 (not (window-dedicated-p)))
  	  (quit-window))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  		      :line 176 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/nano-calendar.org"
  			      176 (error-message-string err))
  		      :error)))))

