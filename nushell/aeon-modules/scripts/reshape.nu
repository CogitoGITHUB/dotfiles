def reshape [] {
    cd /ManifoldOS
    let total = 7

    # 1 — Git
    print $"[1/($total)] Committing pending changes to ManifoldOS..."
    try { git gg out+err> /dev/null } catch { }
    print $"[1/($total)] ✓ Repository is up to date"

    # 2 — Root pull
    print $"[2/($total)] Pulling latest Guix channels for root..."
    let r = (sudo guix pull out+err> /dev/null | complete)
    if $r.exit_code != 0 { print "✗ Root channel pull failed. Aborting."; exit 1 }
    print $"[2/($total)] ✓ Root Guix channels are up to date"

    # 3 — User pull
    print $"[3/($total)] Pulling latest Guix channels for user..."
    let r = (guix pull out+err> /dev/null | complete)
    if $r.exit_code != 0 { print "✗ User channel pull failed. Aborting."; exit 1 }
    print $"[3/($total)] ✓ User Guix channels are up to date"

    # 4 — Reconfigure
    print $"[4/($total)] Reconfiguring system from /ManifoldOS/system.scm..."
    let r = (sudo guix system reconfigure /ManifoldOS/system.scm out+err> /dev/null | complete)
    if $r.exit_code != 0 { print "✗ Reconfigure failed — all generations preserved for rollback."; exit 1 }
    print $"[4/($total)] ✓ System reconfigured successfully"

    # 5 — Prune system gens
    print $"[5/($total)] Removing old system generations..."
    sudo guix system delete-generations out+err> /dev/null
    print $"[5/($total)] ✓ Old system generations deleted, current generation kept"

    # 6 — Prune user gens
    print $"[6/($total)] Removing old user profile generations..."
    guix package --delete-generations=+1 out+err> /dev/null
    print $"[6/($total)] ✓ Old user generations deleted, current profile kept"

    # 7 — GC
    print $"[7/($total)] Running garbage collector on the Guix store..."
    sudo guix gc out+err> /dev/null
    print $"[7/($total)] ✓ Store garbage collected, all unreachable paths removed"

    print "\n✓ ManifoldOS reshape complete — system is clean and up to date.\n"
}