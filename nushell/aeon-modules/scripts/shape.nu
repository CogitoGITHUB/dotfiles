def reshape [] {
    sudo rm -rf /root/.cache/guile/ccache/3.0-LE-8-4.7/ManifoldOS
    sudo guix pull
    sudo guix system reconfigure /ManifoldOS/constitution.scm
}