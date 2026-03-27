(define-module (core-system user-space root users aoeu)
  #:use-module (guix gexp)
  #:use-module (gnu system accounts)
  #:use-module (gnu system setuid)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages nushell)
  #:export (users sudoers-file setuid-programs))

(define-public users
  (list (user-account
         (name "aoeu")
         (comment "Aoeu")
         (group "users")
         (home-directory "/home/aoeu")
         (supplementary-groups '("wheel" "netdev" "audio" "video" "uinput" "keyd" "docker"))
         (shell (file-append nushell "/bin/nu")))))

(define-public sudoers-file
  (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

(define-public setuid-programs
  (list (setuid-program
         (program (file-append sudo "/bin/sudo")))))
