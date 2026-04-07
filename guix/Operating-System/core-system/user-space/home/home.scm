(define-module (core-system user-space home home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services xdg)
  #:use-module (gnu services guix)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix gexp)
  #:use-module (core-system user-space home loaders audio)
  #:use-module (core-system user-space root editors emacs-packages)
  #:export (literative-home-environment))

(define-public literative-home-environment
  (home-environment
    (services
      (append
        home-audio-services
        (list
          ;; Home-wide packages - available in user's ~/.guix-home/profile
          (simple-service 'home-packages
                          home-profile-service-type
                          (list emacs-leaf
                                literate-config-system
                                opencode
                                emacs-avy
                                emacs-geiser
                                emacs-geiser-guile
                                emacs-god-mode
                                emacs-modus-themes
                                emacs-multiple-cursors
                                emacs-mcp))
          (simple-service 'wireplumber-config
                          home-xdg-configuration-files-service-type
                          (list (list "wireplumber/wireplumber.conf.d/disable-logind.conf"
                                     (plain-file "disable-logind.conf"
                                                 "wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}")))))))))