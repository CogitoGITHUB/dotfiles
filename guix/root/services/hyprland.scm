;;; Hyprland service configuration
(define-public literativeos-hyprland-service-type
  (service-type (name 'literativeos-hyprland)
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
