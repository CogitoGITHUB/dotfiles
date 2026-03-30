;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders grafana-stack)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (guix gexp)
  #:use-module (core-system user-space root grafana-stack sops packages sops)
  #:use-module (core-system user-space root grafana-stack sops secrets)
  #:use-module (core-system user-space root grafana-stack sops state)
  #:use-module (core-system user-space root grafana-stack sops self)
  #:use-module (core-system user-space root grafana-stack sops services sops)
  #:use-module (core-system user-space root grafana-stack oci services configuration)
  #:use-module (core-system user-space root grafana-stack oci services grafana)
  #:use-module (core-system user-space root grafana-stack oci services prometheus)
  #:re-export (sops-secrets-service-type
               oci-grafana-service-type
               oci-prometheus-service-type
               oci-blackbox-exporter-service-type)
  #:export (sops-package
            root-grafana-stack-services))

(define-public sops-package sops)

(define %blackbox-exporter-file
  (plain-file "blackbox.yml"
              "modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: [HTTP/1.1, HTTP/2.0]
      valid_status_codes: []
      method: GET
"))

(define-public root-grafana-stack-services
  (list
   (service docker-service-type)
   (service oci-prometheus-service-type
            (oci-prometheus-configuration
             (record (prometheus-configuration))))
   (service oci-grafana-service-type)
   (service oci-blackbox-exporter-service-type
            (oci-blackbox-exporter-configuration
             (file %blackbox-exporter-file)))))