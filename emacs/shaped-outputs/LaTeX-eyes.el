;;; -*- lexical-binding: t -*-

(leaf latex-eyes
  :init
  (condition-case err
      (progn
        (defvar latex-eyes-package-dir
  	(expand-file-name "~/.config/emacs/local-packages/latex-eyes")
  	"Directory where LaTeX Eyes package files are stored.")
        (unless (file-directory-p latex-eyes-package-dir)
  	(make-directory latex-eyes-package-dir t))
        (add-to-list 'load-path latex-eyes-package-dir))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 8 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      8 (error-message-string err))
  		      :error))))
  
  :config
  (condition-case err
      (progn
        (defgroup latex-eyes nil
  	"Visual page-based editing for LaTeX manuscripts." :group
  	'text :prefix "latex-eyes-")
        (defcustom latex-eyes-lines-per-page 36
  	"Number of visual lines per page.\nApproximates Times New Roman 12pt at 1.5 line spacing."
  	:type 'integer :group 'latex-eyes)
        (defcustom latex-eyes-line-spacing 8
  	"Additional spacing between lines in pixels." :type 'integer
  	:group 'latex-eyes)
        (defcustom latex-eyes-body-width 69
  	"Body width in characters.\nApproximates standard letter-size page margins."
  	:type 'integer :group 'latex-eyes)
        (defcustom latex-eyes-use-footnotes t
  	"Enable inline footnote visualization." :type 'boolean :group
  	'latex-eyes)
        (defcustom latex-eyes-page-header-function
  	(lambda (&optional page-number)
  	  (or (org-get-title) "Untitled Document"))
  	"Function to generate page headers.\nCalled with page number as argument."
  	:type 'function :group 'latex-eyes)
        (defcustom latex-eyes-page-footer-function
  	(lambda (&optional page-number) (format "Page %d" page-number))
  	"Function to generate page footers.\nCalled with page number as argument."
  	:type 'function :group 'latex-eyes)
        (defvar-local latex-eyes--page-overlays (make-hash-table)
  	"Hash table mapping page numbers to overlay objects.")
        (defvar-local latex-eyes--max-page 1
  	"Highest calculated page number.")
        (defvar-local latex-eyes--cache-invalid-from nil
  	"First line with invalid cached height.")
        (defvar-local latex-eyes--body-face-cookie nil
  	"Cookie for face remapping.")
        (defvar-local latex-eyes--debug-mode nil
  	"Whether debug overlays are shown."))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 25 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      25 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defface latex-eyes-body-face
  	'((t :family "Times New Roman" :height 120))
  	"Face for document body text." :group 'latex-eyes)
        (defface latex-eyes-pagebreak-face
  	'((t :inherit tab-bar :family "monospace" :foreground "white"))
  	"Face for page break lines." :group 'latex-eyes)
        (defface latex-eyes-header-face
  	'((t :inherit default :family "monospace" :weight bold :slant
  	     italic))
  	"Face for page headers." :group 'latex-eyes)
        (defface latex-eyes-footer-face
  	'((t :inherit default :family "monospace" :weight bold))
  	"Face for page footers." :group 'latex-eyes)
        (defface latex-eyes-footnote-face
  	'((t :inherit default :height 0.8 :slant italic))
  	"Face for inline footnotes." :group 'latex-eyes))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 91 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      91 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defvar latex-eyes-footnote-regex "\\[fn::\\([^]]+\\)\\]"
  	"Regex for matching org-mode inline footnotes.")
        (defun latex-eyes--superscript-number (n)
  	"Convert number N to superscript string."
  	(let
  	    ((digits ["⁰" "¹" "²" "³" "⁴" "⁵" "⁶" "⁷" "⁸" "⁹"])
  	     (result ""))
  	  (if (= n 0) "⁰"
  	    (while (> n 0)
  	      (setq result (concat (aref digits (% n 10)) result))
  	      (setq n (/ n 10)))
  	    result)))
        (defun latex-eyes-clear-footnotes nil
  	"Remove all footnote overlays."
  	(remove-overlays (point-min) (point-max) 'latex-eyes-footnote
  			 t))
        (defun latex-eyes-process-footnotes (beg end)
  	"Process and visualize footnotes between BEG and END."
  	(save-excursion
  	  (goto-char beg)
  	  (let ((fn-index 0))
  	    (while (re-search-forward latex-eyes-footnote-regex end t)
  	      (setq fn-index (1+ fn-index))
  	      (let*
  		  ((content (match-string 1))
  		   (match-beg (match-beginning 0))
  		   (match-end (match-end 0))
  		   (sup (latex-eyes--superscript-number fn-index))
  		   (hide-ov (make-overlay match-beg match-end))
  		   (sup-ov (make-overlay match-beg match-end)))
  		(overlay-put hide-ov 'invisible t)
  		(overlay-put hide-ov 'latex-eyes-footnote t)
  		(overlay-put sup-ov 'after-string sup)
  		(overlay-put sup-ov 'latex-eyes-footnote t)
  		(overlay-put sup-ov 'fn-content content)
  		(overlay-put sup-ov 'fn-index fn-index)))))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 133 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      133 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-compute-line-height (&optional line)
  	"Compute visual height of physical LINE (defaults to current)."
  	(save-excursion
  	  (when line (goto-char (point-min)) (forward-line (1- line)))
  	  (let*
  	      ((start (line-beginning-position))
  	       (end (line-end-position)))
  	    (if (= start end) 1 (count-screen-lines start end)))))
        (defun latex-eyes-get-line-height (&optional line)
  	"Get cached or computed height for LINE."
  	(save-excursion
  	  (when line (goto-char (point-min)) (forward-line (1- line)))
  	  (beginning-of-line)
  	  (or (get-text-property (point) 'latex-eyes-line-height)
  	      (let ((height (latex-eyes-compute-line-height)))
  		(put-text-property (point)
  				   (min (1+ (point)) (point-max))
  				   'latex-eyes-line-height height)
  		height))))
        (defun latex-eyes-get-cumulative-height (&optional line)
  	"Get cumulative visual height up to LINE."
  	(unless line (setq line (line-number-at-pos)))
  	(save-excursion
  	  (goto-char (point-min))
  	  (let ((cumulative 0))
  	    (dotimes (i (1- line))
  	      (setq cumulative
  		    (+ cumulative (latex-eyes-get-line-height (1+ i)))))
  	    cumulative))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 184 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      184 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-clear-pagebreaks nil
  	"Remove all page break overlays."
  	(remove-overlays (point-min) (point-max) 'latex-eyes-pagebreak
  			 t)
  	(setq latex-eyes--page-overlays (make-hash-table))
  	(setq latex-eyes--max-page 1))
        (defun latex-eyes--make-pagebreak-string (height)
  	"Create pagebreak separator string with HEIGHT lines."
  	(propertize " " 'display
  		    `
  		    ((space :width ,(+ 1 (window-body-width)) :height
  			    ,height))
  		    'face 'latex-eyes-pagebreak-face))
        (defun latex-eyes--make-header-string (page-number)
  	"Create header string for PAGE-NUMBER."
  	(let*
  	    ((text
  	      (funcall latex-eyes-page-header-function page-number))
  	     (width latex-eyes-body-width)
  	     (padding (/ (- width (length text)) 2)))
  	  (propertize (concat (make-string padding 32) text "\n")
  		      'face 'latex-eyes-header-face)))
        (defun latex-eyes--make-footer-string (page-number)
  	"Create footer string for PAGE-NUMBER."
  	(let*
  	    ((text
  	      (funcall latex-eyes-page-footer-function page-number))
  	     (width latex-eyes-body-width)
  	     (padding (/ (- width (length text)) 2)))
  	  (propertize (concat "\n" (make-string padding 32) text "\n")
  		      'face 'latex-eyes-footer-face)))
        (defun latex-eyes-apply-pagebreak (page-number)
  	"Apply page break overlay for PAGE-NUMBER at point."
  	(let*
  	    ((ov (make-overlay (point) (point)))
  	     (footer (latex-eyes--make-footer-string page-number))
  	     (pagebreak (latex-eyes--make-pagebreak-string 3))
  	     (header (latex-eyes--make-header-string (1+ page-number))))
  	  (overlay-put ov 'latex-eyes-pagebreak t)
  	  (overlay-put ov 'before-string header)
  	  (overlay-put ov 'after-string (concat footer pagebreak))
  	  (puthash page-number ov latex-eyes--page-overlays)
  	  (when (> page-number latex-eyes--max-page)
  	    (setq latex-eyes--max-page page-number)))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 229 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      229 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-reflow-region (start end)
  	"Reflow pages in region between START and END."
  	(save-excursion
  	  (goto-char start)
  	  (let ((cumulative 0) (current-page 0))
  	    (while (< (point) end)
  	      (let*
  		  ((line-height (latex-eyes-get-line-height))
  		   (new-cumulative (+ cumulative line-height))
  		   (new-page
  		    (/ new-cumulative latex-eyes-lines-per-page)))
  		(when (> new-page current-page)
  		  (latex-eyes-apply-pagebreak new-page)
  		  (setq current-page new-page))
  		(setq cumulative new-cumulative) (forward-line 1))))))
        (defun latex-eyes-reflow-visible nil
  	"Reflow currently visible region." (interactive)
  	(latex-eyes-reflow-region (window-start) (window-end nil t)))
        (defun latex-eyes-reflow-buffer nil
  	"Reflow entire buffer." (interactive)
  	(latex-eyes-clear-pagebreaks)
  	(latex-eyes-reflow-region (point-min) (point-max))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 282 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      282 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-handle-change (beg end _len)
  	"Handle buffer changes for incremental reflow."
  	(let ((inhibit-read-only t))
  	  (remove-text-properties beg (min (1+ end) (point-max))
  				  '(latex-eyes-line-height nil))
  	  (let ((line (line-number-at-pos beg)))
  	    (setq latex-eyes--cache-invalid-from
  		  (min
  		   (or latex-eyes--cache-invalid-from
  		       most-positive-fixnum)
  		   line)))
  	  (when latex-eyes-use-footnotes
  	    (save-excursion
  	      (goto-char beg)
  	      (latex-eyes-process-footnotes (line-beginning-position)
  					    (line-end-position))))))
        (defun latex-eyes--on-scroll (_window display-start)
  	"Handle scrolling to reflow visible region."
  	(latex-eyes-reflow-visible)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 320 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      320 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-setup nil
  	"Setup visual environment for page-based editing."
  	(interactive)
  	(when (require 'olivetti nil t)
  	  (setq-local olivetti-body-width latex-eyes-body-width)
  	  (setq-local olivetti-style 'fancy) (olivetti-mode 1))
  	(setq-local line-spacing latex-eyes-line-spacing)
  	(setq-local default-text-properties
  		    `(line-spacing ,latex-eyes-line-spacing))
  	(when (fboundp 'org-indent-mode) (org-indent-mode -1))
  	(when (fboundp 'diff-hl-mode) (diff-hl-mode -1))
  	(when (fboundp 'hl-line-mode) (hl-line-mode -1))
  	(redraw-display))
        (define-minor-mode latex-eyes-mode
  	"Visual page-based editing mode for LaTeX manuscripts."
  	:lighter " 👁️" :keymap
  	(let ((map (make-sparse-keymap)))
  	  (define-key map (kbd "C-c r") #'latex-eyes-reflow-buffer)
  	  (define-key map (kbd "C-c v") #'latex-eyes-reflow-visible)
  	  map)
  	(if latex-eyes-mode
  	    (progn
  	      (setq latex-eyes--body-face-cookie
  		    (face-remap-add-relative 'default
  					     (face-attr-construct
  					      'latex-eyes-body-face)))
  	      (add-hook 'after-change-functions
  			#'latex-eyes-handle-change nil t)
  	      (add-hook 'window-scroll-functions
  			#'latex-eyes--on-scroll nil t)
  	      (jit-lock-register #'latex-eyes-reflow-region)
  	      (latex-eyes-setup) (latex-eyes-reflow-visible)
  	      (when latex-eyes-use-footnotes
  		(latex-eyes-process-footnotes (point-min) (point-max))))
  	  (progn
  	    (remove-hook 'after-change-functions
  			 #'latex-eyes-handle-change t)
  	    (remove-hook 'window-scroll-functions
  			 #'latex-eyes--on-scroll t)
  	    (jit-lock-unregister #'latex-eyes-reflow-region)
  	    (latex-eyes-clear-pagebreaks) (latex-eyes-clear-footnotes)
  	    (when latex-eyes--body-face-cookie
  	      (face-remap-remove-relative latex-eyes--body-face-cookie)
  	      (setq latex-eyes--body-face-cookie nil))
  	    (remove-text-properties (point-min) (point-max)
  				    '(latex-eyes-line-height nil))))))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 351 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      351 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (defun latex-eyes-maybe-enable nil
  	"Auto-enable latex-eyes-mode for .live files with LaTeX content."
  	(when
  	    (and (buffer-file-name)
  		 (string-suffix-p ".live" (buffer-file-name))
  		 (save-excursion
  		   (goto-char (point-min))
  		   (re-search-forward "^#\\+LATEX_CLASS:" nil t)))
  	  (latex-eyes-mode 1)))
        (add-hook 'org-mode-hook #'latex-eyes-maybe-enable))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 433 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      433 (error-message-string err))
  		      :error))))
  
  (condition-case err
      (progn
        (with-eval-after-load 'evil
  	(evil-define-key 'normal org-mode-map
  	  (kbd "SPC l e") 'latex-eyes-mode (kbd "SPC l r")
  	  'latex-eyes-reflow-buffer (kbd "SPC l v")
  	  'latex-eyes-reflow-visible)))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 452 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      452 (error-message-string err))
  		      :error))))
  
  (condition-case err (progn (provide 'latex-eyes))
    (error
     (add-to-list 'live-shaping-emacs--boot-errors
  		(list :file
  		      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  		      :line 466 :message (error-message-string err)))
     (unless live-shaping-emacs--booting
       (display-warning 'live-shaping-emacs
  		      (format "Error loading %s:%s - %s"
  			      "/home/asdf/.config/emacs/shaping-sources/LaTeX-eyes.org"
  			      466 (error-message-string err))
  		      :error)))))

