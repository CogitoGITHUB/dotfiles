(define-module (core-system user-space root loaders core)
  #:use-module (core-system user-space root core sudo)
  #:use-module (gnu packages base)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages file)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive gzip)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages man)
  #:re-export (sudo gzip)
  #:export (root-core-packages))

(define-public root-core-packages
  (list coreutils
        findutils
        grep
        inetutils
        kmod
        sudo
        util-linux
        patchelf
        file
        wget
        gzip
        tar
        unzip
        ripgrep
        fd
        bat
        man-db
        procps))