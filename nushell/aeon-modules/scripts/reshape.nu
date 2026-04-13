def reshape [] {
    cd /ManifoldOS
    try { git gg } catch { print "nothing to commit, skipping" }
    sudo guix pull
    if $env.LAST_EXIT_CODE == 0 {
        sudo guix system reconfigure /ManifoldOS/constitution.scm
    } else {
        sudo zcat (ls /var/log/guix/drvs/**/*.gz | sort-by modified | last | get name) | tail -20
    }
}