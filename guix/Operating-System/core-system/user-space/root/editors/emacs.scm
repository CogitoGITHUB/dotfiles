(define-module (core-system user-space root editors emacs)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages acl)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (core-system user-space root shell archive unzip)
  #:use-module (core-system user-space root shell archive gzip)
  #:use-module (core-system user-space root shell archive zlib)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages selinux)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages emacs)
  #:export (emacs))

(define-public emacs
  (package
    (name "emacs")
    (version "30.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/emacs/emacs-"
                                  version ".tar.xz"))
              (sha256
               (base32
                "1nggbgnns7lvxn68gzlcsgwh3bigvrbn45kh6dqia9yxlqc6zwxk"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     '(#:configure-flags (list "--with-cairo"
                               "--with-xft"
                               "--with-x-toolkit=gtk")
       #:make-flags
       (list (string-append "SELECTOR="
                            "((not (or (tag :nativecomp) (tag :expensive-test) (tag :unstable)))"))
       #:parallel-build? #f))
    (inputs (list bash-minimal coreutils findutils gawk gzip ncurses sed
                  cairo
                  dbus
                  gtk+
                  giflib
                  harfbuzz
                  libjpeg-turbo
                  libotf
                  libpng
                  librsvg
                  libtiff
                  libx11
                  libxft
                  libxpm
                  libwebp
                  pango
                  poppler
                  gnutls
                  libgccjit
                  mailutils
                  acl
                  alsa-lib
                  elogind
                  ghostscript
                  gpm
                  jansson
                  lcms
                  libice
                  libselinux
                  libsm
                  libxml2
                  m17n-lib
                  sqlite
                  tree-sitter
                  zlib))
    (native-inputs (list autoconf pkg-config texinfo))
    (home-page "https://www.gnu.org/software/emacs/")
    (synopsis "The extensible, customizable, self-documenting text editor")
    (description "GNU Emacs is an extensible and highly customizable text editor.")
    (license license:gpl3+)))
