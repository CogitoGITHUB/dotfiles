;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root security age)
  #:use-module (core-system user-space root security gnupg)
  #:use-module (core-system user-space root security fail2ban)
  #:use-module (core-system user-space root security opensnitch)
  #:use-module (core-system user-space root security sshguard)
  #:use-module (core-system user-space root security password-store)
  #:re-export (age
               gnupg
               fail2ban
               opensnitch-daemon
                opensnitch-ui
                sshguard
                password-store)
  #:export (root-security-packages
            root-security-services))

(define-public root-security-packages
  (list age gnupg fail2ban opensnitch-daemon opensnitch-ui sshguard password-store))

(define-public root-security-services
  '())
