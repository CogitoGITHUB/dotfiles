;;;;; User accounts and sudoers
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

(define-public literativeos-sudoers-file
  (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

(define-public literativeos-setuid-programs
  (list (setuid-program
          (program (file-append sudo "/bin/sudo")))
        (setuid-program
          (program (file-append inetutils "/bin/reboot")))))
