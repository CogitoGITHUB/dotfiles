;;; Home packages aggregator
(use-modules (home packages version-control git)
             (home packages version-control gh)
             (home packages version-control lazygit))

(define-public literativeos-home-packages
  (list nushell starship atuin zoxide fzf carapace
         wezterm zellij
        hyprland hypridle hyprlock hyprpaper hyprsunset grimblast quickshell xdg-desktop-portal-hyprland
        emacs neovim
        opencode
         kanata tailscale tailscaled
         cage gzip bzip2 xz curl findutils git gh lazygit))
