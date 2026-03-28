
;; TAILSCALE SERVE:
;; To expose services via Tailscale, run:
;;   sudo tailscale serve --bg 4096
;; This makes opencode web available at: https://<hostname>.<tailnet>.ts.net/
;; For opencode specifically: https://literative.tail513088.ts.net/
;;
;; To persist or automate Tailscale serve, see:
;; - tailscale.scm for tailscaled service configuration
;; - https://login.tailscale.com/console to manage device name


(add-to-load-path "/home/aoeu/.config/guix/Operating-System")

(use-modules (core-system core-system))
;;(use-modules (systems containers containers))
;; ADD DOCKER WITH IMPURITIVE FS !! 

;; (operating-system
;;   (inherit os)
;;   (services (append all-container-services
;;                     (operating-system-user-services os))))

os
