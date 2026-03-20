;;; Elogind service configuration
(use-modules (gnu services desktop))

(define-public literativeos-elogind-service
  (service elogind-service-type
           (elogind-configuration
            (handle-lid-switch 'ignore)
            (handle-lid-switch-external-power 'ignore)
            (handle-lid-switch-docked 'ignore)
            (handle-power-key 'ignore)
            (handle-suspend-key 'ignore)
            (handle-hibernate-key 'ignore))))
