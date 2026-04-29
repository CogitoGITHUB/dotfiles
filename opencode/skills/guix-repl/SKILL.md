---
name: guix-repl
description: Guix System REPL for interactive Scheme programming, system configuration testing, and package management in ManifoldOS
---

# Guix REPL Skill

You are using the Guix System REPL to interact with GNU Guix declaratively. This skill covers REPL usage, common patterns, and ManifoldOS-specific paths.

## Quick Start

```bash
# Start a Guile REPL with Guix modules loaded
guix repl

# Run a script
guix repl my-script.scm

# Machine-readable REPL (for programmatic interaction)
guix repl --type=machine

# Listen on a socket for remote interaction
guix repl --listen=/tmp/guile-socket
```

## Key Modules

```scheme
;; Load Guix core
(use-modules (guix))

;; Package management
(use-modules (gnu packages base))
(use-modules (gnu packages linux))

;; System configuration
(use-modules (gnu system))
(use-modules (gnu services))

;; REPL shortcut
,use (gnu packages base)
```

## ManifoldOS Paths

- Config root: `/ManifoldOS/Manifold/`
- Main config: `/ManifoldOS/constitution.scm`
- System modules: `/ManifoldOS/Manifold/substrate/`
- User packages: `/ManifoldOS/Manifold/substrate/user-space/root/`
- Loaders: `/ManifoldOS/Manifold/substrate/user-space/root/loaders/`
- Home config: `/ManifoldOS/Manifold/substrate/user-space/home/home.scm`

## Common REPL Commands

```scheme
;; List available packages matching pattern
,apropos "emacs"

;; Build a package
,build coreutils

;; See package details
,describe coreutils

;; Check store path
(guix build coreutils)

;; Load a system configuration
(load "/ManifoldOS/constitution.scm")

;; Evaluate system definition
(operating-system
  (host-name "manifold")
  (timezone "UTC")
  (bootloader (grub-configuration)))
```

## REPL Shortcuts (comma commands)

| Command | Description |
|---------|-------------|
| `,use (module)` | Load a module |
| `,apropos pattern` | Search for packages/bindings |
| `,describe obj` | Show documentation |
| `,build package` | Build a package |
| `,help` | List all REPL commands |

## Interactive Testing

```bash
# Test a package definition
guix repl -- <<'EOF'
(use-modules (gnu packages base))
(build-package coreutils #:source? #t)
EOF

# Evaluate system config without reconfiguring
guix repl -- <<'EOF'
(load "/ManifoldOS/constitution.scm")
(display "Configuration loaded successfully\n")
EOF
```

## Socket-Based REPL

```bash
# Start REPL listening on socket
guix repl --listen=/tmp/guix-repl &

# Connect from another terminal
guile -L /path/to/modules -c '
(use-modules (system repl server))
(connect-to-repl "/tmp/guix-repl")'
```

## Tips

- Use `,quit` or `Ctrl+D` to exit the REPL
- Tab completion works for module names and bindings
- Errors show a backtrace; use `,bt` to see the stack
- The REPL has access to all Guix modules by default
- For ManifoldOS work, always load from `/ManifoldOS/` paths
- Test package changes in REPL before running `guix system reconfigure`
- Use `,help guix` to see Guix-specific REPL commands
