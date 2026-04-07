(define-module (core-system user-space home emacs daemon)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages emacs)
  #:use-module (guix gexp)
  #:export (home-emacs-daemon-service))

(define-public home-emacs-daemon-service
  (simple-service 'emacs-daemon
                  home-shepherd-service-type
                  (list
                    (shepherd-service
                      (provision '(emacs))
                      (documentation "Start the Emacs daemon for use with emacsclient.")
                      (requirement '())
                      (start #~(make-forkexec-constructor
                                 (list #$(file-append emacs "/bin/emacs")
                                       "--daemon")
                                 #:environment-variables
                                 (list (string-append "HOME=" (getenv "HOME"))
                                       (string-append "XDG_RUNTIME_DIR=/run/user/" 
                                                      (number->string (getuid)))
                                       "EMACS_NATIVECOMP_AOTCOMP=no"
                                       "EMACS_NATIVECOMP_DRIVER=no")
                                 #:log-file (string-append (getenv "HOME") "/.emacs.d/daemon.log")
                                 #:directory (getenv "HOME")))
                      (stop #~(make-kill-destructor))
                      (respawn? #f)
                      (one-shot? #f)))))
