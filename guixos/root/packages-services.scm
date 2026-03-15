;; Root System Packages and Services

(use-modules (gnu packages)
             (gnu services)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services shepherd)
             (gnu services base)
             (gnu packages nushell)
             (gnu packages terminals)
             (gnu packages shellutils)
             (gnu packages version-control)
             (gnu packages wm)
             (gnu packages freedesktop)
             (gnu packages xdisorg)
             (shells atuin)
             (shells zellij)
             (vpn tailscale)
             (gnu packages admin)
             (gnu packages nss)
             (tools opencode)
             (tools gh)
             (gnu services xorg))

(load (string-append (getenv "HOME") "/.config/guix/root/terminals/wezterm.scm"))
(load (string-append (getenv "HOME") "/.config/guix/root/shells/fzf.scm"))
(load (string-append (getenv "HOME") "/.config/guix/root/display-manager/ctos-greeter.scm"))

;; Import zoxide from rust-apps
(set! %load-path (cons "/home/aoeu/.config/guix/current/share/guile/site/3.0" %load-path))
(use-modules ((gnu packages rust-apps)))

(define literativeos-root-packages
  (list nushell fzf wezterm atuin zellij zoxide tailscale tailscaled starship opencode gh git nss-certs sudo coreutils hyprland hypridle hyprlock hyprpaper hyprsunset grimblast xdg-desktop-portal-hyprland greetd quickshell cage))

(define (hyprland-etc-service config)
  `(("wayland-sessions/hyprland.desktop"
     ,(plain-file "hyprland.desktop"
       "[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=WaylandSession
DesktopNames=Hyprland
"))))

(define hyprland-service-type
  (service-type (name 'hyprland)
                (extensions
                 (list (service-extension etc-service-type
                                          hyprland-etc-service)))
                (default-value #f)
                (description "Hyprland Wayland compositor service")))

(define literativeos-root-services
  (append (list (service openssh-service-type)
                (service tailscale-service-type)
                (service ctos-greeter-service-type)
                (service hyprland-service-type))
          (delete gdm-service-type %desktop-services)))
