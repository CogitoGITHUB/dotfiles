(define-module (core-system user-space home home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services xdg)
  #:use-module (guix gexp)
  #:use-module (core-system user-space home loaders audio)
  #:export (literative-home-environment))

(define-public literative-home-environment
  (home-environment
    (services
      (append
        home-audio-services
        (list
          (simple-service 'wireplumber-config
                          home-xdg-configuration-files-service-type
                          (list (list "wireplumber/wireplumber.conf.d/disable-logind.conf"
                                     (plain-file "disable-logind.conf"
                                                 "wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}")))))))))