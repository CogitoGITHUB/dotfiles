(define-module (core-system user-space root editors emacs-packages emacs-org-repeat-by-cron)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-org-repeat-by-cron))

(define-public emacs-org-repeat-by-cron
  (package
    (name "emacs-org-repeat-by-cron")
    (version "1.1.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/TomoeMami/org-repeat-by-cron.el")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "188ax1qyjgaz5qj5w1g67hnn7xg9m55j6ymqhd1gks52z0g67cyf"))))
    (build-system emacs-build-system)
    (propagated-inputs (list emacs-org))
    (synopsis "Org-mode task repeater based on Cron expressions")
    (description "org-repeat-by-cron.el is a lightweight extension for Emacs Org-mode that allows you to repeat tasks using the power of Cron expressions. It supports advanced Cron extensions like L (last day), W (nearest weekday), and # (Nth weekday).")
    (home-page "https://github.com/TomoeMami/org-repeat-by-cron.el")
    (license license:gpl3+)))
