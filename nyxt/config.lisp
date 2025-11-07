;;;; ============================================================
;;;; Nyxt — Emacs-defaults + White/Black Minimal Setup
;;;; ============================================================

(in-package #:nyxt-user)

;; ------------------------------------------------------------
;; Enable Emacs bindings and simple, fast behavior
;; ------------------------------------------------------------
(define-configuration buffer
  ((default-modes
    (append
     '(nyxt/mode/emacs:emacs-mode
       nyxt/mode/no-script:no-script-mode
       nyxt/mode/blocker:blocker-mode)
     %slot-value%))))

;; ------------------------------------------------------------
;; Minimal white background / black text theme
;; ------------------------------------------------------------
(define-configuration browser
  ((theme
    (make-instance 'theme:theme
      :background-color "#FFFFFF"
      :text-color "#000000"
      :contrast-text-color "#000000")
    :doc "Minimalist white theme — mirrors default Emacs look.")
   (restore-session-on-startup-p nil)
   (external-editor-program "emacsclient")
   (remote-execution-p t)))

;; ------------------------------------------------------------
;; Clean status bar (title + URL)
;; ------------------------------------------------------------
(define-configuration status-buffer
  ((format-status
    (lambda (status)
      (spinneret:with-html-string
        (:div :style "padding:0 0.5em;font-family:monospace;font-size:10pt;"
          (:span :style "color:#000;" (or (ignore-errors (title (current-buffer))) ""))
          " — "
          (:span :style "color:#333;" (or (ignore-errors (url (current-buffer))) ""))))))))

;; ------------------------------------------------------------
;; Quiet greeting message on startup
;; ------------------------------------------------------------
(defun nyxt-greet (browser)
  (echo "Nyxt ready — Emacs defaults active, white theme loaded."))

(define-configuration browser
  ((after-startup-hook
    (hooks:add-hook %slot-default% 'nyxt-greet))))

;;;; ============================================================
;;;; End of Configuration
;;;; ============================================================

