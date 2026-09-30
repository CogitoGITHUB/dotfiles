;;; foundation-init.el --- generated from AIU-Frame.org
;;
;; ┌─────────────────────────────────────────────────────────────┐
;; │  BOOT ORDER                                                 │
;; │  1. straight.el bootstrap                                   │
;; │  2. straight/build/* → load-path                            │
;; │  3. org from GNU ELPA                                       │
;; │  4. leaf + leaf-keywords                                    │
;; │  5. cyberdeck-emacs (literate loader)                     │
;; │  6. Cyberdeck-Emacs/modules/*.org                         │
;; └─────────────────────────────────────────────────────────────┘

(defun my/init-aiu (fmt &rest args)
  (let ((message-log-max nil)) (apply #'message fmt args)))

;; Boot phase measurement: near-zero overhead timestamp marks.
;; Report lands in *Messages* and ~/.config/emacs/boot-times.log
;; via after-init-hook.  See boot-speed plan Phase A1.
(defvar my/boot-t0 (current-time)
  "Boot start time for phase measurement.")
(defvar my/boot-marks nil
  "Alist of LABEL . SECONDS-SINCE-BOOT, pushed by `my/boot-mark'.")
(defun my/boot-mark (label)
  "Record LABEL with seconds elapsed since `my/boot-t0'."
  (push (cons label (float-time (time-subtract (current-time) my/boot-t0)))
        my/boot-marks))
(defun my/boot-report ()
  "Write phase timings to *Messages* and boot-times.log, plus GC
seconds and the 10 slowest units (measured, never guessed)."
  (let ((marks (nreverse my/boot-marks)) (prev 0.0) (lines nil))
    (dolist (m marks)
      (push (format "%8.2fs (+%6.2fs) %s" (cdr m) (- (cdr m) prev) (car m))
            lines)
      (setq prev (cdr m)))
    (let ((text (mapconcat #'identity (nreverse lines) "\n")))
      (when (and (boundp 'gc-elapsed) my/boot-gc-t0)
        (setq text (concat text (format "\nGC: %.1fs of boot in garbage collection"
                                        (- gc-elapsed my/boot-gc-t0)))))
      (let ((slow (ignore-errors
                    (with-temp-buffer
                      (insert-file-contents
                       (locate-user-emacs-file "unit-times.log"))
                      (goto-char (point-min))
                      (forward-line 1)
                      (buffer-substring-no-properties
                       (point)
                       (save-excursion
                         (forward-line 10) (point)))))))
        (when (and (stringp slow) (not (string-empty-p (string-trim slow))))
          (setq text (concat text "\nSlowest units:\n" slow))))
      (message "BOOT-TIMES:\n%s" text)
      (write-region (concat text "\n") nil
                    (locate-user-emacs-file "boot-times.log") nil 'quiet))))
(add-hook 'after-init-hook #'my/boot-report t)
(defvar my/boot-gc-t0 (and (boundp 'gc-elapsed) gc-elapsed)
  "GC seconds at boot start, for the boot report.")
(my/boot-mark "foundation-start")

;; (my/init-aiu "[init] straight bootstrap…")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (when (file-exists-p bootstrap-file)
    (load bootstrap-file nil 'nomessage)))
;; (my/init-aiu "[init] straight ready")
(my/boot-mark "straight-ready")

(let ((straight-build-dir
       (expand-file-name "straight/build/" user-emacs-directory)))
  (when (file-directory-p straight-build-dir)
    (dolist (dir (directory-files straight-build-dir t "^[^.]" t))
      (when (file-directory-p dir)
        (add-to-list 'load-path dir)))))

(when (file-exists-p "/etc/ssl/certs/ca-certificates.crt")
  (push "GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt" process-environment))

(condition-case nil
    (progn
      (set-face-attribute 'default nil :foreground "#FFFFFF" :background "#000000")
      (set-face-attribute 'mode-line nil :foreground "#FFFFFF" :background "#000000" :box nil)
      (set-face-attribute 'mode-line-inactive nil :foreground "#FFFFFF" :background "#000000" :box nil)
      (set-face-attribute 'header-line nil :foreground "#FFFFFF" :background "#000000"))
  (error nil))

(condition-case nil
    (progn
      (let ((dir (expand-file-name
                  "straight/build/nerd-icons/" user-emacs-directory)))
        (when (file-directory-p dir) (add-to-list 'load-path dir)))
      (require 'nerd-icons))
  (error nil))
;; (my/init-aiu "[init] modeline ready")

;; (my/init-aiu "[init] loading org + leaf…")
(straight-use-package 'org)

(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(eval-and-compile
  (leaf-keywords-init))
;; (my/init-aiu "[init] core ready")
(my/boot-mark "core-ready")

(defvar my/emacs-root
  (file-name-directory
   (or (and (boundp 'manifold--foundation-org)
            manifold--foundation-org)
       (and (boundp 'cyberdeck--foundation-org)
            cyberdeck--foundation-org)
       load-file-name buffer-file-name))
  "Directory holding the AIU Frame org. Derived, never hardcoded.")

(defun my/load-literate-loader (&optional file)
  "Tangle the loader org to ~/.config/emacs/cyberdeck-emacs.el, then load it."
  (or file (setq file
                 (let ((dir my/emacs-root))
                   (or (let ((f (expand-file-name "cyberdeck" dir)))
                         (when (file-exists-p f) f))
                       (let ((f (expand-file-name "cyberdeck-emacs" dir)))
                         (when (file-exists-p f) f))
                       (let ((f (expand-file-name "cyberdeck.org" dir)))
                         (when (file-exists-p f) f))
                       (expand-file-name "cyberdeck-emacs.org" dir)))))
  (unless (file-exists-p file)
    (error "[init] literate loader missing: %s" file))
  (let ((el (locate-user-emacs-file "cyberdeck-emacs.el")))
    ;; (my/init-aiu "[init] tangling loader…")
    ;; Guarded like the AIU Frame tangle: with explicit sync allowed,
    ;; re-tangling an up-to-date loader every boot is pure waste.
    (when (or (not (file-exists-p el)) (file-newer-than-file-p file el))
      (with-demoted-errors "[init] tangle failed: %s"
        (org-babel-tangle-file file)))
    ;; (my/init-aiu "[init] loading literate loader…")
    (load el nil t)))

(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(my/load-literate-loader)
(my/boot-mark "loader-loaded")

;; (my/init-aiu "[init] loader ready — booting modules…")

(setq cyberdeck-emacs--boot-warnings '())
(advice-add 'cyberdeck-emacs-boot :before
            (lambda () (setq cyberdeck-emacs--boot-warnings '())))
(advice-add 'display-warning :before
            (lambda (type message &rest _)
              ;; Single recorder for the whole boot. Our own
              ;; 'cyberdeck-emacs type is already counted by
              ;; record-error — capturing it again would double-count.
              (unless (eq type 'cyberdeck-emacs)
                (if (fboundp 'cyberdeck-emacs-record-warning)
                    (cyberdeck-emacs-record-warning type message)
                  (push (list :type type :message message)
                        cyberdeck-emacs--boot-warnings)))))

(setq cyberdeck-emacs-package-method 'leaf
      cyberdeck-emacs-org-directory
      (expand-file-name "emacs-cyberdeck" my/emacs-root)
      cyberdeck-emacs-output-directory
      (expand-file-name "cyberdeck-emacs" user-emacs-directory))
(setq inhibit-startup-screen t)
(my/boot-mark "boot-start")
(cyberdeck-emacs-boot)
(my/boot-mark "boot-end")

(global-auto-revert-mode 1)
(setq auto-revert-verbose nil
      revert-without-query '(".*")
      global-auto-revert-non-file-buffers t)

;; Everything else lives in <my/emacs-root>/emacs-cyberdeck (extensionless).
;; See keyboard leaders for keybindings.
;; See buffer-management for buffer lifecycle.

;;; foundation-init.el ends here
