#!/usr/bin/env nu
# Hash Getter - Download file and get guix hash

def main [url: string] {
    let tmp_dir = (mktemp -d)
    let filename = ($url | split row "/" | last)
    let filepath = ($tmp_dir | path join $filename)

    print $"Downloading ($url)..."
    curl -L -o $filepath $url

    print $"Computing hash for ($filename)..."
    let hash = (guix hash $filepath | str trim)

    print $"\nHash (base32):"
    print $hash

    print $"\nSHA256 line for package:"
    print $"(sha256 (base32 \"($hash)\"))"

    rm -rf $tmp_dir
}