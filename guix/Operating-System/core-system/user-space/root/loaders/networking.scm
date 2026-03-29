(define-module (core-system user-space root loaders networking)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages nss)
  #:use-module (core-system user-space root networking version-control github-cli)
  #:use-module (core-system user-space root networking version-control lazygit)
  #:use-module (core-system user-space root networking yt-dlp)
  #:use-module (core-system user-space root networking tailscale)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:re-export (yt-dlp)
  #:export (root-networking-packages root-networking-services))

(define-public root-networking-packages
  (list git github-cli lazygit openssh curl yt-dlp tailscale nss-certs))

(define-public root-networking-services
  (list (service iwd-service-type)
        (service config-tailscaled-service-type)))