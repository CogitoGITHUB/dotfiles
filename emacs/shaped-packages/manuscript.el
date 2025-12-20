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
        (defvar shapeshift/denote-formats-dir nil
  	"Export directory for all generated formats (PDF, HTML, etc).")
        (setq shapeshift/denote-silos-dir
  	    (expand-file-name "silos" shapeshift/denote-master-dir))
        (setq shapeshift/denote-formats-dir
  	    (expand-file-name "formats" shapeshift/denote-master-dir))
        (unless (file-directory-p shapeshift/denote-master-dir)
  	(make-directory shapeshift/denote-master-dir t))
        (unless (file-directory-p shapeshift/denote-silos-dir)
  	(make-directory shapeshift/denote-silos-dir t))
        (unless (file-directory-p shapeshift/denote-formats-dir)
  	(make-directory shapeshift/denote-formats-dir t)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 9 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
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
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 96 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      96 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (with-eval-after-load 'org
  	(require 'org-id)
  	(setq org-id-link-to-org-use-id
  	      'create-if-interactive-and-no-custom-id)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 58 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      58 (error-message-string err))
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
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 72 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      72 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (require 'denote) (denote-rename-buffer-mode 1)
        (setq denote-link-backlinks-display-buffer-action
  	    '((display-buffer-reuse-window
  	       display-buffer-below-selected)
  	      (window-height . fit-window-to-buffer))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 119 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      119 (error-message-string err))
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
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 132 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      132 (error-message-string err))
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
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 184 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      184 (error-message-string err))
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
  	     (kws
  	      (if keywords
  		  (concat "_" (mapconcat #'downcase keywords "_"))
  		""))
  	     (sig
  	      (if (string-empty-p signature) ""
  		(concat "==" signature)))
  	     (slug
  	      (replace-regexp-in-string "[^[:alnum:][:digit:]]" "-"
  					(downcase title)))
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
  	  (shapeshift/export-to-all-formats path subdir) path)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 228 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      228 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/get-relative-silo-path (file-path)
  	"Get the relative path from silos directory to FILE-PATH."
  	(file-relative-name (file-name-directory file-path)
  			    shapeshift/denote-silos-dir))
        (defun shapeshift/ensure-formats-mirror-dir
  	  (relative-silo format-ext)
  	"Create mirrored directory structure in formats/FORMAT-EXT/RELATIVE-SILO.\nReturns the full path to the mirror directory."
  	(let*
  	    ((format-base
  	      (expand-file-name format-ext
  				shapeshift/denote-formats-dir))
  	     (mirror-dir (expand-file-name relative-silo format-base)))
  	  (unless (file-directory-p mirror-dir)
  	    (make-directory mirror-dir t))
  	  mirror-dir))
        (defun shapeshift/export-to-all-formats
  	  (live-file original-subdir)
  	"Export LIVE-FILE to all supported formats with mirrored directory structure.\nExports to: txt, tex, html, md, pdf, docx, beamer."
  	(let*
  	    ((relative-silo
  	      (shapeshift/get-relative-silo-path live-file))
  	     (base-name
  	      (file-name-sans-extension
  	       (file-name-nondirectory live-file)))
  	     (formats
  	      '(("txt" . org-ascii-export-to-ascii)
  		("tex" . org-latex-export-to-latex)
  		("html" . org-html-export-to-html)
  		("md" . org-md-export-to-markdown)
  		("pdf" . org-latex-export-to-pdf)
  		("docx" . org-odt-export-to-odt)
  		("beamer" . org-beamer-export-to-pdf))))
  	  (with-current-buffer (find-file-noselect live-file)
  	    (dolist (format-pair formats)
  	      (let*
  		  ((ext (car format-pair))
  		   (export-fn (cdr format-pair))
  		   (mirror-dir
  		    (shapeshift/ensure-formats-mirror-dir
  		     relative-silo ext))
  		   (output-file
  		    (expand-file-name (concat base-name "." ext)
  				      mirror-dir)))
  		(condition-case err
  		    (progn
  		      (funcall export-fn)
  		      (let
  			  ((temp-export
  			    (concat
  			     (file-name-sans-extension live-file) "."
  			     ext)))
  			(when (file-exists-p temp-export)
  			  (rename-file temp-export output-file t)
  			  (message "Exported: %s → formats/%s/"
  				   base-name ext))))
  		  (error
  		   (message "Export to %s failed: %s" ext
  			    (error-message-string err))))))
  	    (let*
  		((org-mirror-dir
  		  (shapeshift/ensure-formats-mirror-dir relative-silo
  							"org"))
  		 (org-copy
  		  (expand-file-name (concat base-name ".org")
  				    org-mirror-dir)))
  	      (copy-file live-file org-copy t))
  	    (message "✓ Exported to all formats in: formats/")))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 307 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      307 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/cleanup-silos nil
  	"Remove all non-.live files from silos directory.\nKeeps only .live source files, removes all exports and temporary files."
  	(interactive)
  	(let
  	    ((files-to-clean
  	      (directory-files-recursively shapeshift/denote-silos-dir
  					   "\\(\\.org\\|\\.tex\\|\\.pdf\\|\\.html\\|\\.txt\\|\\.md\\|\\.odt\\)$")))
  	  (dolist (file files-to-clean)
  	    (when (file-exists-p file)
  	      (delete-file file) (message "Cleaned: %s" file)))
  	  (message "✓ Silos cleaned: only .live files remain"))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 378 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      378 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/auto-export-on-save nil
  	"Auto-export current .live file and clean up silos directory."
  	(when
  	    (and (buffer-file-name)
  		 (string-suffix-p ".live" (buffer-file-name))
  		 (string-prefix-p
  		  (expand-file-name shapeshift/denote-silos-dir)
  		  (expand-file-name (buffer-file-name))))
  	  (let
  	      ((live-file (buffer-file-name))
  	       (subdir (file-name-directory (buffer-file-name))))
  	    (shapeshift/export-to-all-formats live-file subdir)
  	    (shapeshift/cleanup-silos))))
        (add-hook 'after-save-hook #'shapeshift/auto-export-on-save))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 402 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      402 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn (add-to-list 'auto-mode-alist '("\\.live\\'" . org-mode)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 424 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      424 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'org-capture
  	(setq org-capture-templates
  	      '(("n" "New Denote Note (.live format)" plain
  		 (file shapeshift/denote-capture-create-file) ""
  		 :empty-lines 1 :jump-to-captured t :prepare-finalize
  		 (setq shapeshift/source-buffer-for-linking
  		       (current-buffer)))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 434 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      434 (error-message-string err))
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
  	:mode ("\\.pdf\\'" . pdf-view-mode) :hook
  	(pdf-view-mode . pdf-tools-install) :config
  	(setq pdf-view-display-size 'fit-page))
        (setq-default TeX-master nil))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 453 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      453 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar shapeshift/org-latex-export-timer nil
  	"Timer for delayed LaTeX export to avoid excessive rendering.")
        (defun shapeshift/show-pdf-in-split (pdf)
  	"Open PDF in split window with auto-refresh enabled."
  	(when (and pdf (file-exists-p pdf))
  	  (delete-other-windows) (split-window-right) (other-window 1)
  	  (let* ((buffer (find-file-noselect pdf)))
  	    (with-current-buffer buffer
  	      (pdf-view-mode) (auto-revert-mode 1)
  	      (setq buffer-read-only t)
  	      (setq revert-without-query '(".*\\.pdf")))
  	    (switch-to-buffer buffer))
  	  (other-window -1)))
        (defun shapeshift/get-pdf-path-in-formats (org-file)
  	"Get the corresponding PDF path in formats/pdf/ directory for ORG-FILE."
  	(when org-file
  	  (let*
  	      ((relative-path
  		(shapeshift/get-relative-silo-path org-file))
  	       (base-name
  		(file-name-sans-extension
  		 (file-name-nondirectory org-file)))
  	       (pdf-dir
  		(expand-file-name relative-path
  				  (expand-file-name "pdf"
  						    shapeshift/denote-formats-dir))))
  	    (expand-file-name (concat base-name ".pdf") pdf-dir))))
        (defun shapeshift/org-export-and-preview-split nil
  	"Export Org to PDF and show preview in split window with idle delay."
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
  					    (pdf-in-silos
  					     (concat
  					      (file-name-sans-extension
  					       org-file)
  					      ".pdf"))
  					    (pdf-in-formats
  					     (shapeshift/get-pdf-path-in-formats
  					      org-file)))
  					 (org-latex-export-to-pdf)
  					 (when
  					     (file-exists-p
  					      pdf-in-formats)
  					   (shapeshift/show-pdf-in-split
  					    pdf-in-formats)
  					   (message "PDF updated ✓"))
  					 (when
  					     (file-exists-p
  					      pdf-in-silos)
  					   (delete-file pdf-in-silos)))))))))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 482 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      482 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun shapeshift/org-latex-manuscript-mode nil
  	"Enable live-preview manuscript editing workflow."
  	(interactive) (visual-line-mode 1) (org-cdlatex-mode 1)
  	(org-fragtog-mode 1)
  	(setq-local TeX-command-extra-options "-shell-escape")
  	(shapeshift/org-export-and-preview-split)
  	(add-hook 'after-save-hook
  		  #'shapeshift/org-export-and-preview-split nil t)
  	(message "Manuscript mode enabled: Split live preview"))
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
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 542 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      542 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'evil
  	(evil-define-key 'normal org-mode-map
  	  (kbd "SPC n n")
  	  (lambda nil (interactive) (org-capture nil "n"))
  	  (kbd "SPC n d")
  	  (lambda nil (interactive)
  	    (dired shapeshift/denote-silos-dir))
  	  (kbd "SPC n e")
  	  (lambda nil (interactive)
  	    (dired shapeshift/denote-formats-dir))
  	  (kbd "SPC n l") 'denote-link (kbd "SPC n b")
  	  'denote-backlinks (kbd "SPC r f") 'org-roam-node-find
  	  (kbd "SPC r i") 'org-roam-node-insert (kbd "SPC r b")
  	  'org-roam-buffer-toggle (kbd "SPC m m")
  	  'shapeshift/org-latex-manuscript-mode (kbd "SPC m e")
  	  'shapeshift/export-to-all-formats (kbd "SPC m c")
  	  'shapeshift/cleanup-silos)))
    (error
     (add-to-list 'shaping--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  		      :line 577 :message (error-message-string err)))
     (unless shaping--booting
       (display-warning 'shaping
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-packages/manuscript.org"
  			      577 (error-message-string err))
  		      :error)))))

