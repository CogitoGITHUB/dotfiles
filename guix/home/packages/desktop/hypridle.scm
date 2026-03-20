;;;; Hypridle - Hyprland idle daemon
(define-public hypridle (module-ref (resolve-interface '(gnu packages wm)) 'hypridle))

(define hypridle.conf
  (plain-file "hypridle.conf"
   "; Hypridle configuration - very long timeout to prevent idle/sleep
general {
    lock_cmd = hyprlock
    before_sleep_cmd = hyprlock
}

listen {
    timeout = 86400
    on-timeout = echo
}
"))
