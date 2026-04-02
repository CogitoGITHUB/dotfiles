;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root security sops packages)
  #:use-module (core-system user-space root security sops services)
  #:use-module (core-system user-space root security age)
  #:use-module (core-system user-space root security gnupg)
  #:use-module (core-system user-space root security fail2ban)
  #:use-module (core-system user-space root security opensnitch)
  #:use-module (core-system user-space root security ufw)
  #:use-module (core-system user-space root security sshguard)
  #:re-export (sops
               sops-secrets-service-type
               sops-service-configuration
               age
               gnupg
               fail2ban
               opensnitch-daemon
               opensnitch-ui
               ufw
               sshguard)
  #:export (root-security-packages
            root-security-services))

(define-public root-security-packages
  (list sops age gnupg fail2ban opensnitch-daemon opensnitch-ui ufw sshguard))

(define-public root-security-services
  '())
