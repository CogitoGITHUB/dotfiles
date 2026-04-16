def reshape [] {
    cd /ManifoldOS
    clear
    try { git gg } catch { print "nothing to commit, skipping" }
    sudo guix pull
    sudo guix system reconfigure /ManifoldOS/constitution.scm
}