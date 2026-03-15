# AGENTS.md - Guix System Configuration Guide

## IMPORTANT CONTEXT

- System config: `~/.config/guix/system-shaping/system-config.scm`
- Guix commit: `b272a19ad57d34e2869ee2032cb2a64c1ba8afd9`
- Shell: **Always use nushell** - execute commands with `nu -c 'command'`

---

## BUILD & TEST COMMANDS

### System Reconfiguration
```nu
# Source profile first
. /home/aoeu/.guix-profile/etc/profile
export PATH="$HOME/.guix-profile/bin:$PATH"

# Test config (dry run)
guix system build ~/.config/guix/system-shaping/system-config.scm

# Full reconfigure (run in background for long builds)
nohup guix system reconfigure ~/.config/guix/system-shaping/system-config.scm --max-jobs=1 > /tmp/guix.log 2>&1 &

# Rollback if broken
guix system roll-back

# Delete old generations
guix system delete-generations 4m
```

### Package Testing
```nu
# Build a single package definition
guix build -f /home/aoeu/.config/guix/root/tools/opencode.scm

# Test home config in container
guix home container ~/.config/guix/home-config.scm

# Apply home config
guix home reconfigure ~/.config/guix/home-config.scm
```

### Channel Management
```nu
# Always pull before reconfigure
guix pull

# Update channel commit after pull
guix describe  # Get new commit hash, then update channels.scm
```

---

## CODE STYLE GUIDELINES

### Module Structure
- Place modules in appropriate category directory under `root/`
- Use `(define-module ...)` with `#:use-module` for imports
- Prefix license with `license:` (e.g., `license:expat`, `license:asl2.0`)

### Package Definition Pattern
```scheme
(define-module (category package-name)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:))

(define-public package-name
  (package
    (name "package-name")
    (version "X.Y.Z")
    (synopsis "One-line description")
    (description "Full description")
    (home-page "https://example.com")
    (license license:expat)
    (source (origin ...))
    (build-system trivial-build-system)
    (arguments '(#:builder ...)))
```

### Naming Conventions
- **Modules**: lowercase with hyphens `(shells fzf)`, `(tools gh)`
- **Package names**: lowercase with hyphens `fzf`, `opencode`
- **Variables**: lowercase with hyphens `literativeos-root-packages`
- **Service types**: lowercase with hyphens `hyprland-service-type`
- **File names**: lowercase with hyphens `opencode.scm`, `packages-services.scm`

### Common Build Systems
- `gnu-build-system` - Standard GNU build (configure, make, make install)
- `trivial-build-system` - For pre-built binaries
- `cargo-build-system` - Rust/Cargo projects
- `npm-build-system` - Node.js projects

### Common Imports
```scheme
(guix packages)
(guix download)
(guix build-system gnu)
(guix build-system trivial)
((guix licenses) #:prefix license:)
(gnu packages base)
(gnu packages compression)
```

### Re-export Pattern (for wrapper packages)
```scheme
(define-module (shells fzf)
  #:use-module (gnu packages terminals))
(define-public fzf (@ (gnu packages terminals) fzf))
```

### Services Configuration
- Define service types with `(service-type ...)`
- Use `(service-extension ...)` for extending other services
- Append to `%desktop-services` or similar service lists

### Error Handling
- Use `let*` for sequential bindings
- Use `assoc-ref` for accessing output/input alists
- Always return `#t` from install phases if successful

---

## ESSENTIAL TOOLS

If commands missing (ls, grep, etc.):
1. Add to `literativeos-root-packages` in `root/packages-services.scm`
2. Run `guix system reconfigure`

Quick workaround - use system profile:
```nu
/run/current-system/profile/bin/ls
```

Build optimizations (prevent OOM):
```nu
$env.NIX_BUILD_CORES = 1
$env.GUILE_BUILDING = 1
```

---

## FILE ORGANIZATION

```
root/
├── packages-services.scm   # Main package/service list
├── users.scm               # User definitions
├── file-systems.scm        # Filesystem config
├── admin/                  # System admin tools
├── databases/             # Database packages
├── fonts/                 # Font packages
├── gnome/                 # GNOME desktop
├── java/                  # Java ecosystem
├── javascript/            # Node.js packages
├── lisp/                  # Lisp dialects
├── rust/                  # Rust ecosystem
├── shells/                # Shell utilities
├── tools/                 # CLI tools
├── xorg/                  # X11 packages
└── ...
```

---

## REFERENCES

- Guix Manual: https://guix.gnu.org/manual/devel/
- Guix Cookbook: https://guix.gnu.org/cookbook/en/guix-cookbook.html