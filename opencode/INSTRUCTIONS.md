# LiterativeOS - OpenCode Instructions

## Session Memory

At the start of EVERY session, you MUST call `memory_read_graph` to check for previous session context. This ensures continuity across conversations.

After completing significant work, use memory tools to log progress:
- `memory_create_entities` - Create new session/project entries
- `memory_add_observations` - Add notes about decisions and progress
- `memory_create_relations` - Link related entities

## Auto-Save Session Context

IMPORTANT: You MUST automatically save session context before the session ends or when significant work is completed:

1. **On session start**: Check memory for previous context using `memory({ mode: "search", query: "current project status" })` or `memory({ mode: "list", limit: 5 })`

2. **During work**: Periodically save important context:
   - Key decisions made
   - Files modified and why
   - Current work-in-progress state
   - Any blockers or next steps

3. **Before session ends**: Always call:
   ```
   memory({ mode: "add", content: "Session summary: [what was done, current state, next steps, any important context]" })
   ```

Use the opencode-mem plugin for persistent memory:
- `memory({ mode: "add", content: "..." })` - Save to memory
- `memory({ mode: "search", query: "..." })` - Retrieve relevant memories
- `memory({ mode: "list" })` - List all memories

The memory is persistent across sessions and will be available in future conversations.

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
