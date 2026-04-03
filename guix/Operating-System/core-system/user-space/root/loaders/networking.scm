(define-module (core-system user-space root loaders networking)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages networking)
  #:use-module (core-system user-space root networking version-control github-cli)
  #:use-module (core-system user-space root networking version-control lazygit)
  #:use-module (core-system user-space root networking yt-dlp)
  #:use-module (core-system user-space root networking tailscale)
  #:use-module (core-system user-space root networking network-manager)
  #:use-module (core-system user-space root networking gazelle-tui)
  #:use-module (core-system user-space root networking bluetooth)
  #:use-module (core-system user-space root networking tools)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu services base)
  #:re-export (yt-dlp gazelle-tui bluez bluetuith config-tailscaled-service-type
               nmap wireshark bind-dns iperf)
  #:export (root-networking-packages root-networking-services))

(define-public root-networking-packages
  (list git github-cli lazygit openssh curl yt-dlp tailscale nss-certs network-manager gazelle-tui bluez blueman bluetuith nmap wireshark bind-dns iperf))

(define-public root-networking-services
  (list (service network-manager-service-type
                 (network-manager-configuration
                  (iwd? #f)
                  (shepherd-requirement '())))
        (service config-tailscaled-service-type)))