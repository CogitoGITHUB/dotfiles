(define-module (core-system user-space home home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (core-system user-space home loaders audio)
  #:export (literative-home-environment))

(define-public literative-home-environment
  (home-environment
    (services home-audio-services)))