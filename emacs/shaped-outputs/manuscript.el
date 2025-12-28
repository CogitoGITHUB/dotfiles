;;; -*- lexical-binding: t -*-

(leaf denote
  :straight t
  :init
  (condition-case err
      (progn
        (defvar shapeshift/denote-master-dir "~/testing-manuscripts"
  	"Root directory for the manuscript system.")
        (defvar shapeshift/denote-silos-dir nil
  	"Source directory where .live files are created and edited.")
        (setq shapeshift/denote-silos-dir
  	    (expand-file-name "silos" shapeshift/denote-master-dir))
        (unless (file-directory-p shapeshift/denote-master-dir)
  	(make-directory shapeshift/denote-master-dir t))
        (unless (file-directory-p shapeshift/denote-silos-dir)
  	(make-directory shapeshift/denote-silos-dir t)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 9 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      9 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (setq denote-directory
  	    (expand-file-name shapeshift/denote-silos-dir))
        (setq denote-file-type 'org)
        (setq denote-date-format "%Y-%m-%d--%H-%M")
        (setq denote-prompts '(title keywords subdirectory signature))
        (setq org-startup-with-inline-images nil)
        (setq org-startup-folded 'showall))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 81 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      81 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (with-eval-after-load 'org
  	(require 'org-id)
  	(setq org-id-link-to-org-use-id
  	      'create-if-interactive-and-no-custom-id)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 43 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      43 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (use-package org-roam :straight
  	(org-roam :type git :host github :repo "org-roam/org-roam")
  	:after org :init
  	(setq org-roam-directory
  	      (file-truename shapeshift/denote-silos-dir))
  	(setq find-file-visit-truename t) (setq org-roam-v2-ack t)
  	:config (org-roam-db-autosync-mode)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 57 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      57 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (require 'denote) (denote-rename-buffer-mode 1)
        (setq denote-link-backlinks-display-buffer-action
  	    '((display-buffer-reuse-window
  	       display-buffer-below-selected)
  	      (window-height . fit-window-to-buffer))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 106 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      106 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/denote-auto-silo-prompt nil
  	"Prompt for silo and optional sub-silo, creating directories automatically.\nReturns the full path to the selected directory."
  	(let*
  	    ((existing-silos
  	      (seq-filter #'file-directory-p
  			  (directory-files denote-directory t "^[^.]")))
  	     (silo-names
  	      (mapcar (lambda (dir) (file-name-nondirectory dir))
  		      existing-silos))
  	     (silo
  	      (completing-read "Silo (main category): " silo-names nil
  			       nil))
  	     (silo-path (expand-file-name silo denote-directory)))
  	  (unless (file-directory-p silo-path)
  	    (make-directory silo-path t)
  	    (message "Created silo: %s" silo))
  	  (let*
  	      ((existing-subsilo
  		(seq-filter #'file-directory-p
  			    (directory-files silo-path t "^[^.]")))
  	       (subsilo-names
  		(mapcar (lambda (dir) (file-name-nondirectory dir))
  			existing-subsilo))
  	       (subsilo
  		(completing-read "Sub-silo (optional): " subsilo-names
  				 nil nil)))
  	    (if (string-empty-p subsilo) silo-path
  	      (let
  		  ((subsilo-path (expand-file-name subsilo silo-path)))
  		(unless (file-directory-p subsilo-path)
  		  (make-directory subsilo-path t)
  		  (message "Created sub-silo: %s/%s" silo subsilo))
  		subsilo-path)))))
        (advice-add 'denote-subdirectory-prompt :override
  		  #'shapeshift/denote-auto-silo-prompt))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 119 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      119 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshift/source-buffer-for-linking nil
  	"Stores the buffer from which a new note was created for bidirectional linking.")
        (defun shapeshift/insert-bidirectional-link
  	  (source-file new-file)
  	"Create mutual links between SOURCE-FILE and NEW-FILE.\nInserts a link to NEW-FILE in SOURCE-FILE and vice versa."
  	(when (and source-file (file-exists-p source-file))
  	  (with-current-buffer (find-file-noselect source-file)
  	    (save-excursion
  	      (goto-char (point-max)) (unless (bolp) (insert "\n"))
  	      (insert "\n** Related Notes\n")
  	      (org-insert-link nil (concat "id:" (org-id-get-create))
  			       (format "Link to: %s"
  				       (file-name-base new-file)))
  	      (insert "\n"))
  	    (save-buffer))
  	  (with-current-buffer (find-file-noselect new-file)
  	    (save-excursion
  	      (goto-char (point-max)) (unless (bolp) (insert "\n"))
  	      (insert "\n** Related Notes\n")
  	      (org-insert-link nil (concat "id:" (org-id-get-create))
  			       (format "Created from: %s"
  				       (file-name-base source-file)))
  	      (insert "\n"))
  	    (save-buffer)))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 171 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      171 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/denote-capture-create-file nil
  	"Create a new Denote file with .live extension and full frontmatter.\nReturns the path to the created file."
  	(let*
  	    ((title (read-string "Title: "))
  	     (keywords (denote-keywords-prompt))
  	     (subdir (shapeshift/denote-auto-silo-prompt))
  	     (signature
  	      (read-string "Signature (optional): " nil nil ""))
  	     (date (current-time))
  	     (id (format-time-string denote-date-format date))
  	     (date-formatted
  	      (format-time-string denote-date-format date))
  	     (ext ".live")
  	     (slug
  	      (replace-regexp-in-string "[^[:alnum:][:digit:]]" "-"
  					(downcase title)))
  	     (kws
  	      (if keywords
  		  (concat "_" (mapconcat #'downcase keywords "_"))
  		""))
  	     (sig
  	      (if (string-empty-p signature) ""
  		(concat "--"
  			(replace-regexp-in-string
  			 "[^[:alnum:][:digit:]]" "-"
  			 (downcase signature)))))
  	     (filename (concat id "--" slug kws sig ext))
  	     (path (expand-file-name filename subdir))
  	     (org-id (org-id-new))
  	     (frontmatter
  	      (concat "#+TITLE:      " title "\n"
  		      "#+AUTHOR:     Shapeshifter\n" "#+DATE:       "
  		      date-formatted "\n" "#+IDENTIFIER: " id "\n"
  		      "#+FILETAGS:   "
  		      (if keywords (mapconcat #'identity keywords " ")
  			"")
  		      "\n"
  		      (unless (string-empty-p signature)
  			(concat "#+SIGNATURE:  " signature "\n"))
  		      "\n" "#+LATEX_CLASS: article\n"
  		      "#+LATEX_CLASS_OPTIONS: [11pt,a4paper]\n"
  		      "#+LATEX_COMPILER: lualatex\n"
  		      "#+LATEX_HEADER: \\usepackage{amsmath}\n"
  		      "#+LATEX_HEADER: \\usepackage{graphicx}\n"
  		      "#+LATEX_HEADER: \\usepackage{hyperref}\n"
  		      "#+LATEX_HEADER: \\usepackage{fontspec}\n"
  		      "#+OPTIONS: toc:nil num:t\n" "\n" "* " title
  		      "\n" ":PROPERTIES:\n" ":ID:       " org-id "\n"
  		      ":END:\n\n" "Write your manuscript here.\n\n"
  		      "** Section Example\n\n"
  		      "Use LaTeX inline: $E = mc^2$\n\n"
  		      "Display equations:\n" "\\begin{equation}\n"
  		      "\\int_{a}^{b} f(x) dx\n" "\\end{equation}\n")))
  	  (write-region frontmatter nil path)
  	  (when
  	      (and shapeshift/source-buffer-for-linking
  		   (y-or-n-p
  		    "Create bidirectional link with source note? "))
  	    (shapeshift/insert-bidirectional-link
  	     (buffer-file-name shapeshift/source-buffer-for-linking)
  	     path))
  	  path)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 215 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      215 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn (add-to-list 'auto-mode-alist '("\\.live\\'" . org-mode)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 297 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      297 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/create-new-note nil
  	"Create a new denote note with .live extension." (interactive)
  	(setq shapeshift/source-buffer-for-linking (current-buffer))
  	(let ((new-file (shapeshift/denote-capture-create-file)))
  	  (find-file new-file) (goto-char (point-max)))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 307 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      307 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (use-package cdlatex :straight
  	(cdlatex :type git :host github :repo "cdominik/cdlatex"))
        (use-package org-fragtog :straight
  	(org-fragtog :type git :host github :repo "io12/org-fragtog"))
        (use-package auctex :straight
  	(auctex :type git :host github :repo "emacs-straight/auctex"))
        (use-package pdf-tools :straight
  	(pdf-tools :type git :host github :repo "vedang/pdf-tools")
  	:mode ("\\.pdf\\'" . pdf-view-mode) :config
  	(setq pdf-view-display-size 'fit-page)
  	(setq pdf-view-use-scaling t)
  	(setq pdf-view-use-imagemagick nil))
        (setq-default TeX-master nil))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 325 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      325 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshift/org-latex-export-timer nil
  	"Timer for delayed LaTeX export to avoid excessive rendering.")
        (defun shapeshift/cleanup-latex-aux-files (base-path)
  	"Remove LaTeX auxiliary files AND PDF for BASE-PATH.\nRemoves .aux, .log, .out, .toc, .fdb_latexmk, .fls, .tex, .pdf files.\nKeeps only .live files in the silos directory."
  	(let
  	    ((aux-extensions
  	      '(".aux" ".log" ".out" ".toc" ".fdb_latexmk" ".fls"
  		".tex" ".pdf")))
  	  (dolist (ext aux-extensions)
  	    (let ((aux-file (concat base-path ext)))
  	      (when (file-exists-p aux-file) (delete-file aux-file))))))
        (defun shapeshift/show-pdf-in-split (pdf)
  	"Open PDF in split window using pdf-tools with auto-revert."
  	(when (and pdf (file-exists-p pdf))
  	  (let ((original-window (selected-window)))
  	    (delete-other-windows) (split-window-right)
  	    (other-window 1) (find-file pdf) (pdf-view-mode)
  	    (auto-revert-mode 1) (setq auto-revert-interval 0.5)
  	    (select-window original-window))))
        (defun shapeshift/get-pdf-path (org-file)
  	"Get the corresponding PDF path for ORG-FILE in the same directory."
  	(when org-file
  	  (concat (file-name-sans-extension org-file) ".pdf")))
        (defun shapeshift/org-export-and-preview-split nil
  	"Export Org to PDF, move to temp location, show preview in split window, then cleanup."
  	(interactive)
  	(when shapeshift/org-latex-export-timer
  	  (cancel-timer shapeshift/org-latex-export-timer))
  	(setq shapeshift/org-latex-export-timer
  	      (run-with-idle-timer 0.4 nil
  				   (lambda nil
  				     (when (buffer-file-name)
  				       (let*
  					   ((org-file
  					     (buffer-file-name))
  					    (base-path
  					     (file-name-sans-extension
  					      org-file))
  					    (pdf-path
  					     (shapeshift/get-pdf-path
  					      org-file))
  					    (temp-pdf
  					     (expand-file-name
  					      (concat
  					       (file-name-nondirectory
  						base-path)
  					       ".pdf")
  					      temporary-file-directory)))
  					 (condition-case err
  					     (progn
  					       (org-latex-export-to-pdf)
  					       (when
  						   (file-exists-p
  						    pdf-path)
  						 (copy-file pdf-path
  							    temp-pdf t)
  						 (shapeshift/cleanup-latex-aux-files
  						  base-path)
  						 (shapeshift/show-pdf-in-split
  						  temp-pdf)
  						 (message
  						  "PDF updated ✓ (silos kept clean)")))
  					   (error
  					    (message
  					     "Error in PDF export/preview: %s"
  					     (error-message-string err)))))))))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 358 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      358 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/org-latex-manuscript-mode nil
  	"Enable manuscript editing workflow with manual preview."
  	(interactive) (visual-line-mode 1) (org-cdlatex-mode 1)
  	(org-fragtog-mode 1)
  	(setq-local TeX-command-extra-options "-shell-escape")
  	(message "Manuscript mode enabled. Use SPC m p to preview PDF"))
        (defun shapeshift/maybe-enable-manuscript-mode nil
  	"Auto-enable manuscript mode for .live files with LaTeX content."
  	(when
  	    (and (buffer-file-name)
  		 (string-suffix-p ".live" (buffer-file-name))
  		 (save-excursion
  		   (goto-char (point-min))
  		   (re-search-forward "^#\\+LATEX_CLASS:" nil t)))
  	  (shapeshift/org-latex-manuscript-mode)))
        (add-hook 'org-mode-hook
  		#'shapeshift/maybe-enable-manuscript-mode))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 432 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      432 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'evil
  	(evil-define-key 'normal org-mode-map
  	  (kbd "SPC n n") 'shapeshift/create-new-note (kbd "SPC n d")
  	  (lambda nil (interactive)
  	    (dired shapeshift/denote-silos-dir))
  	  (kbd "SPC n l") 'denote-link (kbd "SPC n b")
  	  'denote-backlinks (kbd "SPC r f") 'org-roam-node-find
  	  (kbd "SPC r i") 'org-roam-node-insert (kbd "SPC r b")
  	  'org-roam-buffer-toggle (kbd "SPC m m")
  	  'shapeshift/org-latex-manuscript-mode (kbd "SPC m p")
  	  'shapeshift/org-export-and-preview-split)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  		      :line 464 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/manuscript.org"
  			      464 (error-message-string err))
  		      :error)))))

