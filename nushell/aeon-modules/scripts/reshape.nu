def reshape [] {
    cd /ManifoldOS
    clear
    try { git gg } catch { print "nothing to commit, skipping" }
    try {
        sudo guix pull
    } catch {
        sudo guix repl -- /ManifoldOS/constitution.scm
        return
    }
    try {
        sudo guix system reconfigure /ManifoldOS/constitution.scm
    } catch {
        sudo guix repl -- /ManifoldOS/constitution.scm
    }
}