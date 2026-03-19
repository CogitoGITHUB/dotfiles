;;; Tailscale service configuration
(define (tailscale-shepherd-service config)
  (list (shepherd-service
         (documentation "Run the tailscale daemon")
         (provision '(tailscaled tailscale))
         (requirement '(user-processes))
         (actions '())
         (start
          #~(lambda _
              (fork+exec-command (list #$(file-append tailscaled "/bin/tailscaled")))))
         (stop #~(make-kill-destructor)))))

(define-public literativeos-tailscaled-service-type
  (service-type
   (name 'literativeos-tailscaled)
   (extensions
    (list (service-extension shepherd-root-service-type tailscale-shepherd-service)))
   (default-value '())
   (description "Run tailscaled daemon")))

(define-public literativeos-tailscale-service-type
  (service-type
   (name 'literativeos-tailscale)
   (extensions
    (list (service-extension shepherd-root-service-type
                            (const '()))))
   (default-value '())
   (description "Tailscale client")))
