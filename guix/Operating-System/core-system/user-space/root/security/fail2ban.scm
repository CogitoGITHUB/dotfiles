(define-module (core-system user-space root security fail2ban)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system pyproject)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:export (fail2ban))

;; Simplified from gnu/packages/admin.scm
(define-public fail2ban
  (package
    (name "fail2ban")
    (version "1.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/fail2ban/fail2ban")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0lfakna6ad2xwz95sjxzkavipcsxiy7ybavkdkf9zzmspf2ws4yk"))))
    (build-system pyproject-build-system)
    (arguments
     (list #:tests? #f)) ; Many tests require system access
    (native-inputs (list python-setuptools python-aiosmtpd))
    (inputs (list gawk
                  coreutils-minimal
                  curl
                  grep
                  jq
                  iproute
                  ipset
                  iptables
                  nftables
                  perl
                  python-pyinotify
                  sed
                  sendmail
                  sqlite
                  whois))
    (home-page "http://www.fail2ban.org")
    (synopsis "Daemon to ban hosts that cause multiple authentication errors")
    (description
     "Fail2Ban scans log files and bans IP addresses conducting too many
failed login attempts by updating firewall rules.")
    (license license:gpl2+)))
