(define-module (core-system user-space root editors emacs-packages)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (core-system user-space root editors emacs-packages geiser)
  #:use-module (core-system user-space root editors emacs-packages emacs-sops)
  #:use-module (core-system user-space root editors emacs-packages emacs-tmr)
  #:use-module (core-system user-space root editors emacs-packages emacs-org-repeat-by-cron)
  #:use-module (core-system user-space root editors emacs-packages fuzzy-clock)
  #:use-module (core-system user-space root editors emacs-packages notebook-mode)
  #:use-module (core-system user-space root editors emacs-packages emacs-monkeytype)
  #:re-export (emacs-geiser emacs-geiser-guile emacs-sops emacs-password-store emacs-pass emacs-tmr emacs-org-repeat-by-cron emacs-fuzzy-clock emacs-notebook-mode emacs-monkeytype)
  #:export (root-emacs-packages))

(define-public root-emacs-packages
  (list emacs-geiser emacs-geiser-guile emacs-sops emacs-soap-client emacs-password-store emacs-pass emacs-tmr emacs-org-repeat-by-cron emacs-fuzzy-clock emacs-notebook-mode emacs-monkeytype))
