(define-module (core-system user-space root services greetd)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages admin)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:export (greetd-service-type
            greetd-configuration
            greetd-configuration-command
            greetd-configuration-user))

(define-record-type* <greetd-configuration>
  greetd-configuration make-greetd-configuration
  greetd-configuration?
  (command greetd-configuration-command
           (default "Hyprland --config /home/aoeu/.config/lock-screen/config/greeter.hyprland.conf"))
  (user greetd-configuration-user
        (default "greeter")))

(define (greetd-activation config)
  #~(begin
      (use-modules (guix build utils))
      (mkdir-p "/var/empty")
      ;; Create greetd config
      (let ((config-dir "/etc/greetd")
            (config-file "/etc/greetd/config.toml"))
        (mkdir-p config-dir)
        (call-with-output-file config-file
          (lambda (port)
            (format port "[terminal]~%vt = 1~%~%")
            (format port "[default_session]~%")
            (format port "command = \"~a\"~%" #$(greetd-configuration-command config))
            (format port "user = \"~a\"~%" #$(greetd-configuration-user config)))))
      ;; Create PAM service file for greetd
      (let ((pam-file "/etc/pam.d/greetd"))
        (call-with-output-file pam-file
          (lambda (port)
            (format port "account required pam_unix.so~%")
            (format port "auth required pam_unix.so nullok~%")
            (format port "password required pam_unix.so sha512 shadow~%")
            (format port "session required pam_unix.so~%")
            (format port "session required pam_env.so~%"))))))

(define (greetd-shepherd-service config)
  (list (shepherd-service
          (provision '(greetd))
          (requirement '(user-processes dbus-system))
          (start #~(make-forkexec-constructor
                     (list #$(file-append greetd "/sbin/greetd"))
                     #:user "root"
                     #:log-file "/var/log/greetd.log"))
          (stop #~(make-kill-destructor))
          (respawn? #t))))

(define-public greetd-service-type
  (service-type
    (name 'greetd)
    (extensions (list (service-extension activation-service-type
                                         greetd-activation)
                      (service-extension shepherd-root-service-type
                                         greetd-shepherd-service)))
    (default-value (greetd-configuration))
    (description "Run the greetd login manager daemon.")))
