;;; literate-config-dashboard.el --- Interactive dashboard -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1"))

;;; Code:

(require 'literate-config-scanner)
(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § KEYMAP
;; ════════════════════════════════════════════════════════════════════

(defvar literate-config-dashboard-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'literate-config-dashboard-open-package)
    (define-key map (kbd "r") 'literate-config-dashboard-refresh)
    (define-key map (kbd "p") 'literate-config-dashboard-show-profile)
    (define-key map (kbd "q") 'quit-window)
    (define-key map (kbd "?") 'literate-config-dashboard-help)
    (define-key map (kbd "n") 'next-line)
    (define-key map (kbd "p") 'previous-line)
    map)
  "Keymap for dashboard mode.")

(define-derived-mode literate-config-dashboard-mode special-mode "LitConfig"
  "Major mode for Literate Config dashboard."
  (setq truncate-lines t)
  (setq buffer-read-only t))

;; ════════════════════════════════════════════════════════════════════
;; § STATUS ICONS
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-dashboard--status-icon (status)
  "Get icon for package STATUS."
  (pcase status
    ('loaded "✓")
    ('failed "✗")
    ('disabled "○")
    ('updating "⟳")
    ('unknown "?")))

(defun literate-config-dashboard--status-face (status)
  "Get face for package STATUS."
  (pcase status
    ('loaded 'success)
    ('failed 'error)
    ('disabled 'shadow)
    ('updating 'warning)
    ('unknown 'default)))

;; ════════════════════════════════════════════════════════════════════
;; § RENDERING
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-dashboard-render ()
  "Render the dashboard buffer."
  (let ((inhibit-read-only t))
    (erase-buffer)
    
    ;; Header
    (insert (propertize "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" 
                        'face 'bold))
    (insert (propertize "  LITERATE CONFIG EMACS — Package Dashboard\n" 
                        'face '(:height 1.3 :weight bold)))
    (insert (propertize "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" 
                        'face 'bold))
    
    ;; Statistics
    (let ((total (length literate-config-scanner--packages))
          (loaded (cl-count-if (lambda (p) (eq (plist-get (cdr p) :status) 'loaded))
                               literate-config-scanner--packages))
          (failed (cl-count-if (lambda (p) (eq (plist-get (cdr p) :status) 'failed))
                               literate-config-scanner--packages))
          (total-time (apply #'+ (mapcar #'cdr literate-config-scanner--startup-times))))
      (insert (format "  Total Packages: %d  |  Loaded: %d  |  Failed: %d  |  Startup: %s\n\n"
                      total loaded failed 
                      (literate-config-scanner--format-time total-time))))
    
    ;; Category grouping
    (let ((categories (make-hash-table :test 'equal)))
      (dolist (pkg-info literate-config-scanner--packages)
        (let* ((pkg-name (car pkg-info))
               (category (or (plist-get (cdr pkg-info) :category)
                             (literate-config-scanner--detect-category pkg-name))))
          (push pkg-info (gethash category categories))))
      
      (maphash
       (lambda (category pkgs)
         (insert (propertize (format "  %s\n" (upcase category))
                             'face '(:weight bold :foreground "#51afef")))
         (insert (propertize "  " 'face 'default))
         (insert (propertize (make-string 76 ?─) 'face 'shadow))
         (insert "\n")
         
         (dolist (pkg-info (sort pkgs (lambda (a b) (string< (car a) (car b)))))
           (let* ((pkg-name (car pkg-info))
                  (props (cdr pkg-info))
                  (status (or (plist-get props :status) 'unknown))
                  (time-ms (or (alist-get pkg-name literate-config-scanner--startup-times 
                                          nil nil #'string=) 0))
                  (icon (literate-config-dashboard--status-icon status))
                  (face (literate-config-dashboard--status-face status)))
             
             (insert (format "  %s %s%s%s\n"
                             (propertize icon 'face face)
                             (propertize pkg-name 'face 'default 
                                         'package-name pkg-name)
                             (make-string (max 1 (- 40 (length pkg-name))) ?\s)
                             (if (> time-ms 0)
                                 (propertize (format "%7s" 
                                                     (literate-config-scanner--format-time time-ms))
                                             'face 'shadow)
                               "")))))
         (insert "\n"))
       categories))
    
    ;; Footer
    (insert (propertize "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" 
                        'face 'bold))
    (insert "  Press ? for help\n")
    
    (goto-char (point-min))
    (forward-line 5)))

;; ════════════════════════════════════════════════════════════════════
;; § COMMANDS
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-dashboard-get-package-at-point ()
  "Get package name at point."
  (get-text-property (point) 'package-name))

(defun literate-config-dashboard-open-package ()
  "Open package file at point."
  (interactive)
  (when-let ((pkg-name (literate-config-dashboard-get-package-at-point)))
    (let* ((pkg-info (assoc pkg-name literate-config-scanner--packages))
           (file (plist-get (cdr pkg-info) :file)))
      (when file
        (find-file file)))))

(defun literate-config-dashboard-refresh ()
  "Refresh dashboard."
  (interactive)
  (literate-config-scanner-scan-all)
  (literate-config-dashboard-render))

(defun literate-config-dashboard-show-profile ()
  "Show detailed profiling information."
  (interactive)
  (with-current-buffer (get-buffer-create "*Literate Config Profile*")
    (erase-buffer)
    (insert "═══════════════════════════════════════════════════════════════════════\n")
    (insert "  STARTUP PROFILING\n")
    (insert "═══════════════════════════════════════════════════════════════════════\n\n")
    
    (let ((sorted-times (sort (copy-sequence literate-config-scanner--startup-times)
                              (lambda (a b) (> (cdr a) (cdr b))))))
      (dolist (entry sorted-times)
        (insert (format "  %-30s %10s\n"
                        (car entry)
                        (literate-config-scanner--format-time (cdr entry))))))
    
    (insert (format "\n  Total: %s\n"
                    (literate-config-scanner--format-time
                     (apply #'+ (mapcar #'cdr literate-config-scanner--startup-times)))))
    
    (goto-char (point-min))
    (special-mode)
    (display-buffer (current-buffer))))

(defun literate-config-dashboard-help ()
  "Show dashboard help."
  (interactive)
  (message "RET:open r:refresh p:profile q:quit"))

;;;###autoload
(defun literate-config-dashboard ()
  "Open the package dashboard."
  (interactive)
  (literate-config-scanner-scan-all)
  (switch-to-buffer "*Literate Config Dashboard*")
  (literate-config-dashboard-mode)
  (literate-config-dashboard-render))

(provide 'literate-config-dashboard)
;;; literate-config-dashboard.el ends here
