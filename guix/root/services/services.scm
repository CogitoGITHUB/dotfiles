;;;;; Services aggregator
(use-modules (gnu services)
             (gnu services linux)
             (gnu services base)
             (gnu system)
             (gnu services linux)
             (guix gexp))

;; Note: keyd and kanata services are loaded by config.scm from home/packages/utils/

(define literativeos-desktop-services
  (filter (lambda (s)
            (not (memq (service-type-name (service-kind s))
                       '(gdm gdm-autologin gdm-launch-environment elogind))))
          %desktop-services))

;; Note: Elogind is already included in %desktop-services
;; To customize elogind settings, you would need to remove from %desktop-services first

;; Load uinput module at boot for kanata keyboard remapper
(define literativeos-kernel-modules
  (service kernel-module-loader-service-type
           (list "uinput")))

;; Add uinput group
(define uinput-group-service
  (simple-service 'uinput-group account-service-type
                  (list (user-group (name "uinput"))
                        (user-group (name "keyd")))))

(define-public literativeos-services
  (append (list literativeos-openssh-service
                (service literativeos-hyprland-service-type)

                (service literativeos-tailscaled-service-type)
                (service literativeos-keyd-service-type)
                (service literativeos-kanata-service-type)
                literativeos-kernel-modules
                uinput-group-service
                ;; Add uinput udev rules
                (udev-rules-service 'uinput
                  (udev-rule
                   "90-uinput.rules"
                   "KERNEL==\"uinput\", GROUP=\"uinput\", MODE=\"0660\"\n"))
                (service elogind-service-type
                         (elogind-configuration
                          (handle-lid-switch 'ignore)
                          (handle-lid-switch-external-power 'ignore)
                          (handle-lid-switch-docked 'ignore)
                          (handle-power-key 'ignore)
                          (handle-suspend-key 'ignore)
                          (handle-hibernate-key 'ignore))))
          literativeos-desktop-services))
