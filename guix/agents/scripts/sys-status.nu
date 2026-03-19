#!/usr/bin/env nu
# System Status - Show current system state

def main [] {
    print "=== LiterativeOS Status ==="
    print ""
    
    print "System Generations:"
    guix system list-generations | lines | head 10
    
    print ""
    print "Profile Packages:"
    guix package --list-installed | lines | length | print $"  ($in) packages"
    
    print ""
    print "Services:"
    herd status | lines | head 15
}