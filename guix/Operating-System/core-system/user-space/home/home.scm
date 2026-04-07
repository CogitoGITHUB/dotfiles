(define-module (core-system user-space home home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services guix)
  #:use-module (guix gexp)
  #:use-module (core-system user-space home loaders audio)
  #:use-module (core-system user-space home loaders emacs)
  #:use-module (core-system user-space root editors emacs-packages)
  #:export (literative-home-environment))

(define-public literative-home-environment
  (home-environment
    (services
      (append
        home-audio-services
        home-emacs-services
        (list
          ;; Home-wide packages - available in user's ~/.guix-home/profile
          (simple-service 'home-packages
                          home-profile-service-type
                          root-emacs-packages)
          (simple-service 'wireplumber-config
                          home-xdg-configuration-files-service-type
                          (list (list "wireplumber/wireplumber.conf.d/disable-logind.conf"
                                     (plain-file "disable-logind.conf"
                                                 "wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}")))))))))