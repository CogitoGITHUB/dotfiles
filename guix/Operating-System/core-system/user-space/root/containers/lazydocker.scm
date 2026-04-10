(define-module (core-system user-space root containers lazydocker)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive gzip)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (lazydocker))

(define-public lazydocker
  (package
    (name "lazydocker")
    (version "0.24.1")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/jesseduffield/lazydocker/releases/download/v0.24.1/lazydocker_0.24.1_Linux_x86_64.tar.gz")
        (sha256 (base32 "19fls72l772bbrsjkdazqbanf8hz3j6295kq3pzhs0p133vaq726"))))
    (build-system trivial-build-system)
    (inputs (list tar gzip))
    (arguments
      (list #:modules (quote ((guix build utils)))
            #:builder
        (quasiquote (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                 (gzip (string-append (assoc-ref %build-inputs "gzip") "/bin")))
            (setenv "PATH" gzip)
            (mkdir-p (string-append out "/bin"))
            (invoke tar "-xzf" src "-C" (string-append out "/bin") "lazydocker"))))))
    (home-page "https://github.com/jesseduffield/lazydocker")
    (synopsis "Docker TUI")
    (description "A simple terminal UI for docker and docker-compose.")
    (license license:expat)))