# LiterativeOS - OpenCode Instructions

## System Overview

This is a Guix-based system configuration. Guix uses Scheme (Lisp) for declarative system configuration.

## Key Paths

- Config root: `/home/aoeu/.config/guix/`
- Main config: `guixos.scm`
- System modules: `Operating-System/core-system/`
- User packages: `Operating-System/core-system/user-space/root/`
- Loaders: `Operating-System/core-system/user-space/root/loaders/`

## Package Management

Packages are defined in category subdirectories under `user-space/root/`:
- `core/` - Core utilities
- `networking/` - Network tools (git, ssh, curl)
- `shell/` - Shell tools (nushell, starship, fzf)
- `editors/` - Editors (emacs, neovim)
- `desktop/` - Desktop environment (hyprland)
- `terminal/` - Terminal emulators (wezterm)
- `containers/` - Docker, lazydocker
- `keyboard/` - Keyd, kanata
- `ai/` - OpenCode, kilo
- `programming-languages/` - Guile

## Adding Packages

1. Create a module file in the appropriate category directory
2. Add to the corresponding loader in `loaders/`
3. Run: `sudo guix system reconfigure ~/.config/guix/guixos.scm`

## Services

Services are defined in individual `.scm` files and aggregated in loaders.

## Documentation

See `guix-agents/` directory for detailed guides.
