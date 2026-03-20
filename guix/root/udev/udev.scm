;;;;; udev rules for uinput access
(define-public uinput-udev-rule
  (udev-rule
   "90-uinput.rules"
   (string-append "KERNEL==\"uinput\", GROUP=\"uinput\", MODE=\"0660\"\n")))

;; Add uinput group
(define uinput-group-service
  (simple-service 'uinput-group account-service-type
                  (list (user-group (name "uinput")))))

(define-public literativeos-udev-rules
  (list uinput-udev-rule))
