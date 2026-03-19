#!/usr/bin/env nu
# Package Search - Search guix packages

def main [query: string] {
    let results = (guix package -A $query | lines | head 20)
    
    if ($results | is-empty) {
        print "No results found"
        return
    }

    for line in $results {
        let parts = ($line | split column -n 2 '\s+')
        print $parts.0
    }
}