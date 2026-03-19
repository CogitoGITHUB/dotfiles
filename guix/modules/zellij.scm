;; Zellij - Terminal multiplexer
(use-modules (guix packages)
             (guix download)
             (guix build-system trivial)
             ((guix licenses) #:prefix license:)
             (gnu packages base)
             (gnu packages compression))

(define-public zellij
  (package
    (name "zellij")
    (version "0.40.1")
    (synopsis "Terminal multiplexer and workspace manager")
    (description "Zellij is a terminal multiplexer and workspace manager")
    (home-page "https://zellij.dev")
    (license license:expat)
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/zellij-org/zellij/releases/download/v0.40.1/zellij-x86_64-unknown-linux-musl.tar.gz")
       (sha256 (base32 "03rp4k9hw4f19i498qfy818qp2vi1ndlw0nfw0lxhbxvv7r3xzd9"))))
    (build-system trivial-build-system)
    (native-inputs (list coreutils tar gzip))
    (arguments
     '(#:builder
       (let* ((out (assoc-ref %outputs "out"))
              (src (assoc-ref %build-inputs "source"))
              (coreutils (assoc-ref %build-inputs "coreutils"))
              (tar (assoc-ref %build-inputs "tar"))
              (gzip (assoc-ref %build-inputs "gzip"))
              (tarbin (string-append tar "/bin/tar"))
              (mvbin (string-append coreutils "/bin/mv"))
              (chmodbin (string-append coreutils "/bin/chmod"))
              (mkdirbin (string-append coreutils "/bin/mkdir")))
          (setenv "PATH" (string-append coreutils "/bin:" tar "/bin:" gzip "/bin"))
          (system (string-append mkdirbin " -p " out))
          (system (string-append tarbin " -xzf " src " -C " out))
          (system (string-append chmodbin " a+x " out "/zellij"))
          (system (string-append mkdirbin " -p " out "/bin"))
          (system (string-append mvbin " " out "/zellij " out "/bin/zellij")))))))
