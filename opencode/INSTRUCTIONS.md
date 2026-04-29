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

This is a Guix-based system configuration called ManifoldOS. 

## Key Paths

- Config root: `/ManifoldOS/Manifold/` 
- Main config: `/ManifoldOS/system.scm`
- System modules: `Manifold/substrate/`
- User packages: `Manifold/substrate/user-space/root/`
- Loaders: `Manifold/substrate/user-space/root/loaders/`
- Home config: `Manifold/substrate/user-space/home/home.scm`

## Adding Packages

1. Create a module file in the appropriate category directory
2. Add to the corresponding loader in `loaders/`
3. Run: `sudo guix system reconfigure /ManifoldOS/system.scm`

## Services

Services are defined in individual `.scm` files and aggregated in loaders.

## Audio Configuration

- MPD config: `Manifold/substrate/user-space/root/audio/music/mpd.scm`
- Home audio: `Manifold/substrate/user-space/home/home.scm` (includes pulsemixer + pulseaudio restart shepherd)

## Documentation

See `council/` directory for detailed guides.
