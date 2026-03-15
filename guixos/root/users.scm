;; Users Configuration

(use-modules (gnu packages bash)
             (gnu packages nushell)
             (gnu system shadow))

(define literativeos-users
  (cons* (user-account
              (name "aoeu")
              (comment "Aoeu")
              (group "users")
              (home-directory "/home/aoeu")
              (shell (file-append nushell "/bin/nu"))
              (supplementary-groups '("wheel" "netdev" "audio" "video")))
           %base-user-accounts))
