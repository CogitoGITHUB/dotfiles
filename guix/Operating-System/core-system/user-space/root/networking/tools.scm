(define-module (core-system user-space root networking tools)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages networking)
  #:use-module ((gnu packages dns) #:select (isc-bind))
  #:re-export (nmap wireshark iperf)
  #:export (bind-dns))

(define-public bind-dns isc-bind)
