;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root security age)
  #:use-module (core-system user-space root security gnupg)
  #:use-module (core-system user-space root security fail2ban)
  #:use-module (core-system user-space root security opensnitch)
  #:use-module (core-system user-space root security sshguard)
  #:re-export (age
               gnupg
               fail2ban
               opensnitch-daemon
                opensnitch-ui
                sshguard)
  #:export (root-security-packages
            root-security-services))

(define-public root-security-packages
  (list age gnupg fail2ban opensnitch-daemon opensnitch-ui sshguard))

(define-public root-security-services
  '())
