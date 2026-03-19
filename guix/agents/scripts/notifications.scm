;;;; Notifications - Ntfy notification system for LiterativeOS
;;;; Sends notifications when builds complete or confirmation needed
;;;; Uses ntfy.sh (free, no setup required)

(define-module (literativeos notifications)
  #:use-module (ice-9 format)
  #:use-module (ice-9 regex)
  #:export (notify notify-confirmation-needed notify-build-complete notify-summary))

(define ntfy-server "ntfy.sh")
(define ntfy-topic "literativeos")  ; Change this to your topic

(define (send-notification title message)
  "Send notification via ntfy"
  (let* ((cmd (format #f "curl -s -H \"Title: ~a\" -d \"~a\" ~a/~a"
                      title message ntfy-server ntfy-topic))
         (result (system cmd)))
    result))

(define (notify title message)
  "Send a basic notification"
  (format #t "[NOTIFY] ~a: ~a~%" title message)
  (send-notification title message))

(define (notify-confirmation-needed prompt)
  "Notify that confirmation is needed from user"
  (notify "CONFIRMATION NEEDED" prompt))

(define (notify-build-complete success? message)
  "Notify about build completion"
  (let ((status (if success? "BUILD OK" "BUILD FAILED")))
    (notify status message)))

(define (notify-summary session-name actions-list)
  "Send a summary of what was done in this session"
  (let ((summary (string-join actions-list "\n- ")))
    (notify (string-append "Session: " session-name)
            (string-append "- " summary))))

;; Helper to format summary
(define (format-actions-summary actions)
  "Format a list of actions into a summary string"
  (if (null? actions)
      "No actions"
      (string-join (map (lambda (action)
                          (if (string? action) action (object->string action)))
                        actions)
                   ", ")))