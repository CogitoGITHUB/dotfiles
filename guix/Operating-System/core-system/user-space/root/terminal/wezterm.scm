(define-module (core-system user-space root terminal wezterm)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (wezterm))

(define-public wezterm
  (let ((commit "05343b387085842b434d267f91b6b0ec157e4331")
        (date "20260117.154428"))
    (package
      (name "wezterm")
      (version (string-append date "." (substring commit 0 8)))
      (source
       (origin
         (method git-fetch)
         (file-name "wezterm")
         (uri (git-reference
               (url "https://github.com/wezterm/wezterm")
               (commit commit)))
         (sha256
          (base32 "1pkng8dvjc917j4i8sly8cz91nx1yh2k83i78rcs43gdxs79gjds"))))
      (build-system cargo-build-system)
      (arguments '(#:install-source? #f))
      (home-page "https://wezfurlong.org/wezterm/")
      (synopsis "GPU-accelerated cross-platform terminal emulator")
      (description "Wezterm is a modern cross-platform terminal emulator written in Rust.")
      (license license:asl2.0))))
