;;; Services aggregator
(define literativeos-desktop-services
  (filter (lambda (s)
            (not (memq (service-type-name (service-kind s))
                       '(gdm gdm-autologin gdm-launch-environment))))
          %desktop-services))

(define-public literativeos-services
  (append (list literativeos-openssh-service
                (service literativeos-hyprland-service-type)
                (service literativeos-kanata-service-type)
                (service literativeos-tailscaled-service-type))
          literativeos-desktop-services))
