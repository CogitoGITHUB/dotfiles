;;;; System Build Complete - Build and reconfigure system with notifications
;;;; Usage: cd ~/.config/guix && guix repl -- agents/scripts/sys-build-complete.scm

(use-modules (ice-9 format))

(define config-path "/home/aoeu/.config/guix/config.scm")
(define ntfy-topic "literativeos")

(define (display-msg msg)
  (format #t "~a~%" msg))

(define (notify title message)
  "Send notification via ntfy"
  (let ((cmd (format #f "curl -s -H \"~a\" -d \"~a\" ntfy.sh/~a" title message ntfy-topic)))
    (system cmd)))

(define (main)
  (display-msg "=== LiterativeOS System Build ===")
  (display-msg (string-append "Config: " config-path))
  (display-msg "")
  (display-msg "Building system...")
  (display-msg "")

  ;; Run build
  (let ((exit-status (system (string-append "sudo guix system reconfigure " config-path))))
    (newline)

    (cond
     ((not (zero? exit-status))
      (display-msg "[ERROR] BUILD FAILED - non-zero exit code!")
      (display-msg "Fix errors before continuing."))
     ;; Only send notification on success, not on failure
     (else
      (display-msg "[OK] Build completed.")
      (display-msg "")
      (notify "BUILD OK" "System reconfigure completed successfully.")
      (display-msg "Should I git push the changes? (yes/no)")
      (display-msg "(Note: Due to Guix REPL limitations, git push skipped automatically)")
      (display-msg "Run manually: cd ~/.config/guix && git add -A && git commit -m 'System update' && git push")))))

;; Run main when executed as script
(main)