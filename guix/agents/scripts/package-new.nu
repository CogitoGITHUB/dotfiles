#!/usr/bin/env nu
# Package New - Generate new package .scm file

# Usage: package-new <name> <version> <url> <type>
# type: gnu, trivial, reexport

def main [name: string, version: string, url: string, type: string = "gnu"] {
    let base_dir = "~/.config/guix/home/packages"
    
    let template = if $type == "gnu" {
        $"(char 59)(char 59)(char 59);;;; (($name | str title-case) | str downcase) shell history
(define-public ($name | str downcase)
  (package
    (name "($name | str downcase)")
    (version "($version)")
    (synopsis "Package for ($name)")
    (description "Package for ($name)")
    (home-page "https://github.com/example/($name)")
    (license expat)
    (source
     (origin
       (method url-fetch)
       (uri "($url)")
       (sha256 (base32 "HASH"))
       (file-name (string-append "($name | str downcase)" "-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'build)
                  (delete 'check)
                  (delete 'configure)
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (install-file "($name | str downcase)" (string-append out "/bin"))
                        #t)))))))"
    } else if $type == "trivial" {
        $"(char 59)(char 59)(char 59);;;; (($name | str title-case) | str downcase)
(define-public ($name | str downcase)
  (package
    (name "($name | str downcase)")
    (version "($version)")
    (synopsis "Package for ($name)")
    (description "Package for ($name)")
    (home-page "https://github.com/example/($name)")
    (license expat)
    (source
     (origin
       (method url-fetch)
       (uri "($url)")
       (sha256 (base32 "HASH"))
       (file-name (string-append "($name | str downcase)" "-" version ".tar.gz"))))
    (build-system trivial-build-system)
    (native-inputs (list coreutils tar gzip patchelf glibc))
    (arguments
     '(#:builder
       (let* ((out (assoc-ref %outputs "out"))
              (src (assoc-ref %build-inputs "source"))
              (coreutils (assoc-ref %build-inputs "coreutils"))
              (tar (assoc-ref %build-inputs "tar"))
              (gzip (assoc-ref %build-inputs "gzip"))
              (patchelf (assoc-ref %build-inputs "patchelf"))
              (glibc (assoc-ref %build-inputs "glibc"))
              (tarbin (string-append tar "/bin/tar"))
              (mvbin (string-append coreutils "/bin/mv"))
              (chmodbin (string-append coreutils "/bin/chmod"))
              (mkdirbin (string-append coreutils "/bin/mkdir"))
              (patchelf-bin (string-append patchelf "/bin/patchelf"))
              (ld-linux (string-append glibc "/lib/ld-linux-x86-64.so.2")))
          (setenv "PATH" (string-append coreutils "/bin:" tar "/bin:" gzip "/bin"))
          (system (string-append mkdirbin " -p " out))
          (system (string-append tarbin " -xzf " src " -C " out))
          (system (string-append chmodbin " a+x " out "/(($name | str downcase))"))
          (system (string-append mkdirbin " -p " out "/bin"))
          (system (string-append mvbin " " out "/(($name | str downcase)) " out "/bin/(($name | str downcase))"))
          (system (string-append patchelf-bin " --set-interpreter " ld-linux " " out "/bin/(($name | str downcase))")))))))"
    } else {
        $"(char 59)(char 59)(char 59);;;; (($name | str title-case) | str downcase)
(define-public ($name | str downcase) (module-ref (resolve-interface '(gnu packages nushell)) '($name | str downcase)))"
    }

    print $"Template for ($name):"
    print $template
    print ""
    print "Save to appropriate category folder and add to packages.scm"
}