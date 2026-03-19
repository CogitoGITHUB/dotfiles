;;; Kanata keyboard remapper service
(define-public literativeos-kanata-service-type
  (service-type
    (name 'literativeos-kanata)
    (extensions
     (list (service-extension shepherd-root-service-type
                             (const (list
                               (shepherd-service
                                 (documentation "Kanata keyboard remapper")
                                 (provision '(kanata))
                                 (respawn? #t)
                                 (start #~(make-forkexec-constructor
                                           (list (string-append #$kanata "/bin/kanata")
                                                 "-c" (string-append (getenv "HOME") "/.config/kanata/kanata.kbd"))
                                           #:user (getenv "USER")
                                           #:group "users"
                                           #:environment-variables '("WAYLAND_DISPLAY")))
                                 (stop #~(make-kill-destructor))))))))
    (default-value #t)
    (description "Kanata keyboard remapper")))
