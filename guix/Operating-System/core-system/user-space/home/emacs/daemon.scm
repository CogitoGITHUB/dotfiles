(define-module (core-system user-space home emacs daemon)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages emacs)
  #:use-module (guix gexp)
  #:export (home-emacs-daemon-service))

(define-public home-emacs-daemon-service
  "Start Emacs daemon at login so emacsclient can connect immediately.
The daemon uses the LiterativeOS emacs configuration with all guix packages."
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
                                 #:log-file (string-append (getenv "HOME") "/.emacs.d/daemon.log")))
                      (stop #~(make-kill-destructor))
                      (respawn? #f)))))
