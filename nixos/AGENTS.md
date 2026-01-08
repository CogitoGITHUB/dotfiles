# System Configuration Agents

This is a comprehensive system configuration repository managing the "shapeless" NixOS host with Wayland compositor (Niri/Scroll), shell configurations, and application settings.

## Build Commands
- `sudo nixos-rebuild switch` - Apply configuration and switch to new generation
- `sudo nixos-rebuild build` - Build configuration without switching  
- `sudo nixos-rebuild test` - Test configuration temporarily
- `nix flake update` - Update flake inputs
- `nix flake check` - Check flake configuration

## Application-Specific Commands
- **Neovim**: `nvim --headless -c "lua require('lazy').check()"` - Check plugins
- **Tmux**: `tmux source-file ~/.config/tmux/tmux.conf` - Reload config
- **Nushell**: `nu --help` for testing, modules auto-load on start
- **Wezterm**: `wezterm --config ~/.config/wezterm/wezterm.lua` for validation

## Code Style Guidelines

### Nix (Primary)
- Use 2-space indentation for Nix expressions
- Follow NixOS module structure: imports -> options -> config
- Group related configurations with descriptive comments using `--- SECTION ---`
- Use snake_case for option names, camelCase for variables
- Prefer attribute sets over let-bindings for simple values
- Keep lines under 80 characters when possible
- Use trailing commas for multi-line attribute lists

### Lua (Neovim/Wezterm)
- Use 2-space indentation
- Prefer local variables over global
- Use snake_case for function and variable names
- End files with `return config` or `return module` pattern

### Nushell
- Use snake_case for variable and function names
- Prefer `def` over `let` for reusable functions
- Module structure: imports -> functions -> main logic

### KDL (Niri)
- Use hierarchical indentation with consistent spacing
- Group related settings in blocks
- Comment complex keybindings with descriptions

### Lisp (Nyxt/Emacs)
- Use kebab-case for function and variable names
- Follow `defconfiguration` and `define-configuration` patterns
- Use docstrings extensively

## Error Handling
- Always test NixOS config with `nixos-rebuild build` before switching
- Use `nix flake check` to validate flake structure
- Check systemd logs with `journalctl -u service-name` for service issues
- Test Wayland compositor changes with `niri --debug` before restart
- Validate shell configs by sourcing in test sessions

## Testing
- Test individual services with `systemctl status service-name`
- Verify hardware support with `lspci`, `lsusb` for device detection
- Test user configurations by switching to new generation first
- Test terminal multiplexer configs in separate sessions
- Validate keybindings in compositor debug mode