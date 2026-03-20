# Guix system rebuild script
# Usage: nu ~/.config/nushell/aeon-modules/scripts/guix/gr.nu

print "Building Guix system..."

sudo guix system reconfigure ~/.config/guix/config.scm

if $env.LAST_EXIT_CODE == 0 {
    print "Build successful! Committing changes..."
    
    cd ~/.config/guix
    
    git add .
    
    let status = (git status --short)
    
    if ($status | is-empty) {
        print "No changes to commit"
    } else {
        let timestamp = (date now | format date "%Y-%m-%d %H:%M")
        git commit -m $"($timestamp)"
        git push
        print "Changes committed and pushed!"
    }
} else {
    print "Build failed!"
}
