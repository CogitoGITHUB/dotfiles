;;; Greetd service configuration
(use-modules (gnu services)
             (gnu services desktop))

(define literativeos-desktop-services
  (filter (lambda (s)
            (not (memq (service-type-name (service-kind s))
                       '(gdm gdm-autologin gdm-launch-environment elogind))))
          %desktop-services))

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

(define-public literativeos-services
  (append (list literativeos-openssh-service
                literativeos-elogind-service
                (service literativeos-tailscaled-service-type)
                (service literativeos-hyprland-service-type)
                (service literativeos-keyd-service-type)
                (service literativeos-kanata-service-type)
                (service literativeos-greetd-service-type)
                literativeos-kernel-modules
                uinput-group-service
                (udev-rules-service 'uinput uinput-udev-rule))
          literativeos-desktop-services))
