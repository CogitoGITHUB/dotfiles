;;;; Kanata - keyboard customization daemon
(define-public kanata (module-ref (resolve-interface '(gnu packages rust-apps)) 'kanata))

(define (kanata-shepherd-service config)
  (list (shepherd-service
         (documentation "kanata - keyboard customization daemon")
         (provision '(kanata))
         (respawn? #t)
         (start #~(make-forkexec-constructor
                   (list (string-append #$kanata "/bin/kanata")
                         "-c" "/home/aoeu/.config/kanata/kanata.kbd")
                   #:user "aoeu"
                   #:group "uinput"
                   #:environment-variables (list "WAYLAND_DISPLAY")))
         (stop #~(make-kill-destructor)))))

(define-public literativeos-kanata-service-type
  (service-type
   (name 'literativeos-kanata)
   (extensions
    (list (service-extension shepherd-root-service-type kanata-shepherd-service)))
   (default-value #t)
   (description "kanata keyboard customization daemon")))
