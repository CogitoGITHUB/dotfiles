(define-module (core-system user-space root loaders networking)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages networking)
  #:use-module ((gnu packages admin) #:select (wpa-supplicant))
  #:use-module ((gnu packages networking) #:select (iwd))
  #:use-module (gnu packages linux)
  #:use-module (core-system user-space root networking version-control github-cli)
  #:use-module (core-system user-space root networking version-control lazygit)
  #:use-module (core-system user-space root networking yt-dlp)
  #:use-module (core-system user-space root networking tailscale)
  #:use-module (core-system user-space root networking network-manager)
  #:use-module (core-system user-space root networking gazelle-tui)
  #:use-module (core-system user-space root networking bluetooth)
  #:use-module (core-system user-space root networking bluetuith)
  #:use-module (core-system user-space root networking tools)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (guix gexp)
  #:re-export (yt-dlp gazelle-tui bluez bluetuith config-tailscaled-service-type
               nmap wireshark bind-dns iperf iproute wpa-supplicant iwd)
  #:export (root-networking-packages root-networking-services))

(define-public root-networking-packages
  (list git github-cli lazygit openssh curl yt-dlp tailscale nss-certs network-manager gazelle-tui bluez bluetuith nmap wireshark bind-dns iperf iproute wpa-supplicant iwd))

(define-public root-networking-services
  (list (service network-manager-service-type
                 (network-manager-configuration
                  (shepherd-requirement '(iwd))))
        (service iwd-service-type
                 (iwd-configuration
                  (config
                   (iwd-settings
                    (general
                     (iwd-general-settings
                      (enable-network-configuration? #t)))
                    (network
                     (iwd-network-settings
                      (name-resolving-service 'none)))))))
        (service bluetooth-service-type
                 (bluetooth-configuration
                  (auto-enable? #t)))
        (service config-tailscaled-service-type)))
