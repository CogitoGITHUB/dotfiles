(define-module (core-system user-space root security ufw)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python)
  #:export (ufw))

(define-public ufw
  (package
    (name "ufw")
    (version "0.36.2")
    (source (origin
              (method url-fetch)
              (uri "https://launchpad.net/ufw/0.36/0.36.2/+download/ufw-0.36.2.tar.gz")
              (sha256
               (base32
                "1xcbhd1xck205vi5cm26z1ckgbhbnch2bv9p6pdl8szgxjgajmra"))))
    (build-system gnu-build-system)
    (inputs (list python))
    (arguments
     '(#:make-flags (list (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (home-page "https://launchpad.net/ufw")
    (synopsis "Uncomplicated Firewall - frontend for iptables/nftables")
    (description "UFW provides a user-friendly interface for managing
netfilter/iptables-based firewalls. It aims to be easy to use while
providing a lightweight and extensible framework for complex firewall rules.")
    (license license:gpl2+)))
