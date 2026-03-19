;;; Greetd service configuration
(define-public literativeos-greetd-service-type
  (service-type (name 'literativeos-greetd)
                (extensions
                 (list (service-extension etc-service-type
                                          (lambda (config)
                                            `(("greetd/config.toml"
                                               ,(plain-file "config.toml"
                                                 "[terminal]\nvt = 1\n\n[default_session]\ncommand = \"env HYPRLAND_CONFIG=/etc/ctos/greeter.hyprland.conf CTOS_MODE=greetd quickshell --path /opt/ctOS/greeter.qml\"\nuser = \"greeter\"\n")))))))
                (default-value #f)
                (description "greetd login manager")))
