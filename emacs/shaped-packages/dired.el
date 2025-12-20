;;; -*- lexical-binding: t -*-

(leaf dired
  :init
  (condition-case err
      (progn
        (setq dired-listing-switches "-alh --group-directories-first"
  	    dired-dwim-target t dired-recursive-copies 'always
  	    dired-recursive-deletes 'always
  	    dired-kill-when-opening-new-dired-buffer t
  	    delete-by-moving-to-trash t auto-revert-verbose nil
  	    auto-revert-interval 1))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 8 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      8 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err (progn (require 'dired) (require 'dired-x))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 23 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      23 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn (add-hook 'dired-mode-hook 'auto-revert-mode))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 29 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      29 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn (add-hook 'dired-mode-hook 'dired-hide-details-mode))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 37 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      37 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'dired-x
  	(setq dired-omit-files
  	      (concat dired-omit-files "\\|^\\.DS_Store$"
  		      "\\|^\\.git$" "\\|^\\.gitignore$"
  		      "\\|^__pycache__$" "\\|^\\.mypy_cache$"
  		      "\\|\\.pyc$" "\\|^node_modules$" "\\|^\\.next$"
  		      "\\|^\\.cache$"))
  	(add-hook 'dired-mode-hook 'dired-omit-mode)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 45 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      45 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshifter/dired-preview-window nil
  	"Window used for file previews.")
        (defvar shapeshifter/dired-preview-buffer nil
  	"Buffer used for file previews.")
        (defvar shapeshifter/dired-auto-preview nil
  	"Enable automatic preview on navigation.")
        (defun shapeshifter/dired-preview-file nil
  	"Preview file at point in a side window." (interactive)
  	(let ((file (dired-get-filename nil t)))
  	  (when file
  	    (if (file-directory-p file)
  		(message "Cannot preview directory: %s" file)
  	      (when
  		  (and shapeshifter/dired-preview-window
  		       (window-live-p
  			shapeshifter/dired-preview-window))
  		(delete-window shapeshifter/dired-preview-window))
  	      (setq shapeshifter/dired-preview-window
  		    (display-buffer-in-side-window
  		     (find-file-noselect file)
  		     '((side . right) (window-width . 0.5))))
  	      (with-selected-window shapeshifter/dired-preview-window
  		(setq shapeshifter/dired-preview-buffer
  		      (current-buffer))
  		(read-only-mode 1))))))
        (defun shapeshifter/dired-preview-close nil
  	"Close the preview window." (interactive)
  	(when
  	    (and shapeshifter/dired-preview-window
  		 (window-live-p shapeshifter/dired-preview-window))
  	  (delete-window shapeshifter/dired-preview-window))
  	(when
  	    (and shapeshifter/dired-preview-buffer
  		 (buffer-live-p shapeshifter/dired-preview-buffer))
  	  (kill-buffer shapeshifter/dired-preview-buffer))
  	(setq shapeshifter/dired-preview-window nil
  	      shapeshifter/dired-preview-buffer nil))
        (defun shapeshifter/dired-toggle-preview-mode nil
  	"Toggle automatic preview on navigation." (interactive)
  	(if shapeshifter/dired-auto-preview
  	    (progn
  	      (setq shapeshifter/dired-auto-preview nil)
  	      (shapeshifter/dired-preview-close)
  	      (message "Auto-preview disabled"))
  	  (setq shapeshifter/dired-auto-preview t)
  	  (message "Auto-preview enabled"))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 65 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      65 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dired-enhanced-open nil
  	"Open file with context awareness." (interactive)
  	(let ((file (dired-get-filename nil t)))
  	  (cond ((file-directory-p file) (dired-find-file))
  		((string-match-p
  		  "\\.\\(jpg\\|jpeg\\|png\\|gif\\|bmp\\|svg\\)\\'"
  		  file)
  		 (find-file file))
  		((string-match-p "\\.\\(mp4\\|mkv\\|avi\\|mov\\)\\'"
  				 file)
  		 (when (executable-find "mpv")
  		   (start-process "mpv" nil "mpv" file))
  		 (message "Opening %s with mpv..."
  			  (file-name-nondirectory file)))
  		((string-match-p "\\.pdf\\'" file)
  		 (start-process "pdf-viewer" nil "xdg-open" file)
  		 (message "Opening %s with external viewer..."
  			  (file-name-nondirectory file)))
  		(t (dired-find-file))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 123 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      123 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dired-create-file nil
  	"Create a new file in current directory." (interactive)
  	(let ((filename (read-string "Create file: ")))
  	  (when (> (length filename) 0)
  	    (write-region "" nil filename) (revert-buffer)
  	    (dired-goto-file filename))))
        (defun shapeshifter/dired-open-as-root nil
  	"Open dired as root using sudo/doas." (interactive)
  	(let ((sudo-cmd (if (executable-find "doas") "doas" "sudo")))
  	  (dired (concat "/" sudo-cmd "::" default-directory))))
        (defun shapeshifter/dired-kill-other-dired-buffers nil
  	"Kill all dired buffers except current one." (interactive)
  	(let ((current (current-buffer)))
  	  (dolist (buf (buffer-list))
  	    (with-current-buffer buf
  	      (when
  		  (and (eq major-mode 'dired-mode)
  		       (not (eq buf current)))
  		(kill-buffer buf)))))
  	(message "Killed all other dired buffers")))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 148 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      148 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dired-sort-by-size nil
  	"Sort dired buffer by file size." (interactive)
  	(dired-sort-other (concat dired-listing-switches "S"))
  	(message "Sorted by size"))
        (defun shapeshifter/dired-sort-by-time nil
  	"Sort dired buffer by modification time." (interactive)
  	(dired-sort-other (concat dired-listing-switches "t"))
  	(message "Sorted by time"))
        (defun shapeshifter/dired-sort-by-extension nil
  	"Sort dired buffer by file extension." (interactive)
  	(dired-sort-other (concat dired-listing-switches "X"))
  	(message "Sorted by extension"))
        (defun shapeshifter/dired-sort-by-name nil
  	"Sort dired buffer by name (default)." (interactive)
  	(dired-sort-other dired-listing-switches)
  	(message "Sorted by name")))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 180 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      180 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dired-file-info nil
  	"Show detailed file information." (interactive)
  	(let*
  	    ((file (dired-get-filename))
  	     (attrs (file-attributes file))
  	     (size
  	      (file-size-human-readable (file-attribute-size attrs)))
  	     (mtime
  	      (format-time-string "%Y-%m-%d %H:%M:%S"
  				  (file-attribute-modification-time
  				   attrs)))
  	     (perms (file-attribute-modes attrs)))
  	  (message "File: %s | Size: %s | Modified: %s | Perms: %s"
  		   (file-name-nondirectory file) size mtime perms)))
        (defun shapeshifter/dired-directory-summary nil
  	"Show summary statistics for current directory." (interactive)
  	(let ((files 0) (dirs 0) (total-size 0))
  	  (dolist (file (directory-files default-directory t "^[^.]"))
  	    (if (file-directory-p file) (setq dirs (1+ dirs))
  	      (setq files (1+ files) total-size
  		    (+ total-size
  		       (file-attribute-size (file-attributes file))))))
  	  (message "Directory: %d files, %d dirs, %s total" files dirs
  		   (file-size-human-readable total-size))))
        (defun shapeshifter/dired-count-marked nil
  	"Count and show marked files." (interactive)
  	(let ((count (length (dired-get-marked-files))))
  	  (message "%d file%s marked" count (if (= count 1) "" "s")))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 210 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      210 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshifter/dired-open-in-external-app nil
  	"Open file with system default application." (interactive)
  	(let ((file (dired-get-filename nil t)))
  	  (call-process "xdg-open" nil 0 nil file)
  	  (message "Opened %s externally"
  		   (file-name-nondirectory file))))
        (defun shapeshifter/dired-copy-path nil
  	"Copy full path of file at point." (interactive)
  	(let ((path (dired-get-filename)))
  	  (kill-new path) (message "Copied: %s" path)))
        (defun shapeshifter/dired-copy-filename-only nil
  	"Copy just the filename without path." (interactive)
  	(let
  	    ((filename (file-name-nondirectory (dired-get-filename))))
  	  (kill-new filename) (message "Copied: %s" filename))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  		      :line 249 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/dired.org"
  			      249 (error-message-string err))
  		      :error)))))

