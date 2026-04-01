(define-module (core-system user-space root ci cuirass)
  #:use-module (guix packages)
  #:use-module (gnu packages ci)
  #:export (cuirass))

(define-public cuirass
  (@@ (gnu packages ci) cuirass))

;; Cuirass service - commented out until needed
;; To enable, uncomment and configure with your build specifications
;; See: https://guix.gnu.org/manual/en/html_node/Continuous-Integration.html
#;(begin
  (use-modules (guix gexp)
               (gnu services)
               (gnu services cuirass)
               (gnu services databases))

  (define %cuirass-specs-content
    ";; Cuirass specifications
    ;; Add your build specifications here
    '()")

  (define %cuirass-specs-file
    (plain-file "cuirass-specs.scm" %cuirass-specs-content))

  (define-public cuirass-service
    (service cuirass-service-type
             (cuirass-configuration
              (specifications %cuirass-specs-file))))

  (define-public root-ci-services
    (list cuirass-service)))
