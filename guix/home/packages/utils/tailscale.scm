;;; Tailscale packages and service
(define-public tailscaled
  (package
    (name "tailscaled")
    (version "1.74.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://pkgs.tailscale.com/stable/tailscale_" version "_amd64.tgz"))
              (sha256 (base32 "12196z8dhdzxq8mjj0rlvhr6wchmi6z33ym36yqqrp4m52xjz7q5"))))
    (build-system trivial-build-system)
    (arguments
     `(#:builder
       (let* ((out (assoc-ref %outputs "out"))
              (src (assoc-ref %build-inputs "source"))
              (tar (assoc-ref %build-inputs "tar"))
              (gzip (assoc-ref %build-inputs "gzip"))
              (coreutils (assoc-ref %build-inputs "coreutils"))
              (tarbin (string-append tar "/bin/tar"))
              (gzipbin (string-append gzip "/bin/gzip"))
              (mkdirbin (string-append coreutils "/bin/mkdir"))
              (installbin (string-append coreutils "/bin/install"))
              (version ,version))
         (setenv "PATH" (string-append tar "/bin:" gzip "/bin:" coreutils "/bin"))
         (system* tarbin "xvzf" src)
         (system* mkdirbin "-p" (string-append out "/bin"))
         (system* installbin "-m755" "-t" (string-append out "/bin")
                  (string-append "tailscale_" version "_amd64/tailscaled"))
         (system* installbin "-m755" "-t" (string-append out "/bin")
                  (string-append "tailscale_" version "_amd64/tailscale")))))
    (native-inputs (list tar gzip coreutils))
    (home-page "https://tailscale.com")
    (synopsis "Tailscale daemon and client")
    (description "Tailscale daemon and client")
    (license bsd-3)))

(define-public tailscale tailscaled)

(define (tailscale-shepherd-service config)
  (let ((tailscaled-bin (file-append tailscaled "/bin/tailscaled")))
    (list (shepherd-service
           (documentation "Run the tailscale daemon")
           (provision '(tailscaled tailscale))
           (requirement '(user-processes))
           (actions '())
           (start #~(lambda _
                     (fork+exec-command (list #$tailscaled-bin))))
           (stop #~(make-kill-destructor))))))

(define-public literativeos-tailscaled-service-type
  (service-type
   (name 'literativeos-tailscaled)
   (extensions
    (list (service-extension shepherd-root-service-type tailscale-shepherd-service)))
   (default-value '())
   (description "Run tailscaled daemon")))

(define-public literativeos-tailscale-service-type
  (service-type
   (name 'literativeos-tailscale)
   (extensions
    (list (service-extension shepherd-root-service-type
                            (const '()))))
   (default-value '())
   (description "Tailscale client")))
