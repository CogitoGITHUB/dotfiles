(define-module (core-system user-space root desktop wayland grimblast)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (core-system user-space root desktop wayland grim)
  #:use-module (core-system user-space root desktop wayland slurp)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (grimblast))

(define-public grimblast
  (let ((commit "9d67858b437d4a1299be496d371b66fc0d3e01f6")
        (revision "1"))
    (package
      (name "grimblast")
      (version (git-version "0.1" revision commit))
      (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/hyprwm/contrib")
                (commit commit)))
          (file-name (git-file-name name version))
          (sha256
            (base32 "1v0v5j7ingx80b5zpyz8ilfhz0kh9dcssnx6iwwl45zzgp915cpv"))))
      (build-system gnu-build-system)
      (arguments
        '(#:tests? #f
          #:make-flags (list (string-append "PREFIX=" (assoc-ref %outputs "out")))
          #:phases
          (modify-phases %standard-phases
            (delete 'configure)
            (add-after 'unpack 'chdir
              (lambda _ (chdir "grimblast"))))))
      (inputs (list grim slurp))
      (home-page "https://github.com/hyprwm/contrib")
      (synopsis "Hyprland screenshot tool")
      (description "Screenshot tool for Hyprland.")
      (license license:bsd-3))))
