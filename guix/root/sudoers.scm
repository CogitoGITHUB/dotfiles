;;; Sudoers and setuid programs
(define-public literativeos-sudoers-file
  (plain-file "sudoers" "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

(define-public literativeos-setuid-programs
  (list (setuid-program
          (program (file-append sudo "/bin/sudo")))))
