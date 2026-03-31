(define-module (core-system user-space root ai ollama)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (ollama))

(define-public ollama
  (package
    (name "ollama")
    (version "0.19.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/ollama/ollama/releases/download/v" version
              "/ollama-linux-amd64.tar.zst"))
        (sha256 (base32 "1lm54ssmcnrhr7yhfb5xwwis22j3ymgvk8a30l1r3rb9lb1vxv5k"))))
    (build-system trivial-build-system)
    (inputs (list bash tar zstd patchelf glibc))
    (arguments
     (list #:modules (quote ((guix build utils)))
           #:builder
           (quasiquote (begin
             (use-modules (guix build utils))
             (let* ((out (assoc-ref %outputs "out"))
                    (src (assoc-ref %build-inputs "source"))
                    (tar-bin (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                    (zstd-bin (string-append (assoc-ref %build-inputs "zstd") "/bin/zstd"))
                    (patchelf (string-append (assoc-ref %build-inputs "patchelf") "/bin/patchelf"))
                    (interp (string-append (assoc-ref %build-inputs "glibc") "/lib/ld-linux-x86-64.so.2"))
                    (ollama-real (string-append out "/bin/ollama-real"))
                    (ollama-bin (string-append out "/bin/ollama")))
               (setenv "PATH" (string-append (assoc-ref %build-inputs "bash") "/bin:" (assoc-ref %build-inputs "tar") "/bin:" (assoc-ref %build-inputs "zstd") "/bin"))
               (mkdir-p (string-append out "/bin"))
               (invoke zstd-bin "-d" "-f" src "-o" "/tmp/ollama.tar")
               (invoke tar-bin "xf" "/tmp/ollama.tar" "-C" (string-append out "/bin"))
               (rename-file (string-append out "/bin/ollama") ollama-real)
               (invoke patchelf "--set-interpreter" interp ollama-real)
               (call-with-output-file ollama-bin
                 (lambda (port)
                   (format port "#!/bin/sh\nexec ~a \"$@\"\n" ollama-real)))
               (chmod ollama-bin #o555))))))
    (home-page "https://ollama.com")
    (synopsis "Get up and running with large language models locally")
    (description "Ollama is a tool for running large language models locally on your machine. It supports Llama, Mistral, Phi, and many other open models.")
    (license license:expat)))
