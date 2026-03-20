;;;;; User accounts
(define %nushell (module-ref (resolve-interface '(gnu packages nushell)) 'nushell))

(define-public literativeos-users
  (cons* (user-account
          (name "aoeu")
          (comment "Aoeu")
          (group "users")
          (home-directory "/home/aoeu")
          (supplementary-groups '("wheel" "netdev" "audio" "video" "uinput" "keyd"))
          (shell (file-append %nushell "/bin/nu")))
        %base-user-accounts))
