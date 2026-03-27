(define-module (core-system user-space root ai ollama)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (ollama))

(define-public ollama
  (package
    (name "ollama")
    (version "0.18.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/ollama/ollama/releases/download/v" version
              "/ollama-linux-amd64.tar.zst"))
        (sha256 (base32 "1h5zfbz4b6rrx7n7r7k3ga4v903xw0q4wanhfvn5hbxm2chsnwis"))))
    (build-system trivial-build-system)
    (inputs (list tar zstd))
    (arguments
      (list #:modules (quote ((guix build utils)))
            #:builder
        (quasiquote (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (src (assoc-ref %build-inputs "source"))
                 (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                 (zstd (string-append (assoc-ref %build-inputs "zstd") "/bin/zstd")))
            (setenv "PATH" (string-append zstd ":" (or (getenv "PATH") "")))
            (mkdir-p (string-append out "/bin"))
            (invoke tar "--use-compress-program=zstd" "-xf" src
                    "-C" (string-append out "/bin")))))))
    (home-page "https://ollama.com")
    (synopsis "Get up and running with large language models")
    (description "Ollama is a tool that allows you to run open-source large language models locally.")
    (license license:expat)))

ollama