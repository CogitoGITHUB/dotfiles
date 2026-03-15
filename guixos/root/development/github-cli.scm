;; NONGNU packages - GitHub CLI
;;
;; LiterativeOS custom: GitHub command line tool
;; This module provides the gh package

(define-module (nongnu packages github-cli)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (gh))

(define %glibc-lib "/gnu/store/yj053cys0724p7vs9kir808x7fivz17m-glibc-2.41/lib")

(define gh
  (package
    (name "gh")
    (version "2.48.0")
    (synopsis "GitHub command line tool")
    (description "GitHub CLI is a tool that brings GitHub to your terminal.
It simplifies and streamlines git and GitHub interaction.
gh is designed to be used as a command-line client to GitHub.com and GitHub Enterprise Server.")
    (home-page "https://github.com/cli/cli")
    (license license:expat)
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:builder
      #~(let* ((out (assoc-ref %outputs "out"))
               (bin-dir (string-append out "/bin")))
          (mkdir-p bin-dir)
          ;; Create wrapper script for gh
          (call-with-output-file (string-append bin-dir "/gh")
            (lambda (port)
              (format port "#!/run/current-system/profile/bin/bash~%
exec ~a/ld-linux-x86-64.so.2 --library-path ~a /usr/bin/gh \"$@\"~%"
                      %glibc-lib %glibc-lib)))
          (chmod (string-append bin-dir "/gh") #o755))))))
