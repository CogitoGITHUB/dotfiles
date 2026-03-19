;; Desktop environment module
(use-modules (gnu services)
             (gnu services shepherd)
             (gnu services xorg)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu packages wm)
             (gnu packages freedesktop)
             (gnu packages xdisorg))

(define-public greetd-service-type
  (service-type (name 'greetd)
                (extensions
                 (list (service-extension etc-service-type
                                          (lambda (config)
                                            `(("greetd/config.toml"
                                               ,(plain-file "config.toml"
                                                 "[terminal]\nvt = 1\n\n[default_session]\ncommand = \"env HYPRLAND_CONFIG=/etc/ctos/greeter.hyprland.conf CTOS_MODE=greetd quickshell --path /opt/ctOS/greeter.qml\"\nuser = \"greeter\"\n")))))))
                (default-value #f)
                (description "greetd login manager")))

(define-public hyprland-service-type
  (service-type (name 'hyprland)
                (extensions
                 (list (service-extension etc-service-type
                                          (lambda (config)
                                            `(("wayland-sessions/hyprland.desktop"
                                               ,(plain-file "hyprland.desktop"
                                                 "[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=WaylandSession
DesktopNames=Hyprland
")))))))
                (default-value #f)
                (description "Hyprland Wayland compositor service")))
