;;; Git Configuration
(define-module (tools git)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module ((guix licenses) #:prefix license:))

(define-public git-config
  (package
    (name "git-config")
    (version "0.0.0")
    (synopsis "Git configuration for LiterativeOS")
    (description "Sets up git user configuration")
    (home-page "https://git-scm.com")
    (license license:gpl3)
    (source #f)
    (build-system trivial-build-system)
    (arguments
     '(#:builder
       (let ((out (assoc-ref %outputs "out"))
             (home (getenv "HOME")))
         (mkdir-p (string-append out "/etc"))
         (call-with-output-file (string-append out "/etc/gitconfig")
           (lambda (port)
             (display "[user]" port)
             (newline port)
             (display "	name = aoeu" port)
             (newline port)
             (display "	email = aoeu@localhost" port)
             (newline port)))
         #t)))))

git-config
