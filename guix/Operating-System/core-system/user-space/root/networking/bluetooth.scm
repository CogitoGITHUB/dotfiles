(define-module (core-system user-space root networking bluetooth)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages calendar)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages pkg-config)
  #:export (bluez bluetuith))

(define-public bluez
  (package
    (name "bluez")
    (version "5.79")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "mirror://kernel.org/linux/bluetooth/bluez-"
                            version ".tar.xz"))
        (sha256
          (base32 "12pal1m4xlr8k7kxb6isv5lbaca2wc5zcgy0907wfwcz78qaar21"))))
    (build-system gnu-build-system)
    (arguments
      '(#:configure-flags
        (list "--sysconfdir=/etc"
              "--localstatedir=/var"
              "--enable-library"
              "--enable-wiimote"
              "--disable-systemd"
              "--enable-hid2hci")))
    (native-inputs (list gettext-minimal pkg-config))
    (inputs (list glib dbus eudev libical readline))
    (home-page "https://www.bluez.org/")
    (synopsis "Linux Bluetooth protocol stack")
    (description
      "BlueZ provides support for the core Bluetooth layers and protocols.")
    (license license:gpl2+)))

(define-public bluetuith
  (package
    (name "bluetuith")
    (version "0.2.6")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/bluetuith-org/bluetuith/releases/download/v" version "/bluetuith_" version "_Linux_x86_64.tar.gz"))
        (sha256
          (base32 "05r7lvpqlxib591zf74i29xg0gpdc7wqip07k7issin42qfp61pj"))))
    (build-system copy-build-system)
    (arguments
      '(#:install-plan
        '(("bluetuith" "bin/bluetuith"))))
    (home-page "https://github.com/bluetuith-org/bluetuith")
    (synopsis "Cross-platform TUI bluetooth manager")
    (description "bluetuith is a TUI-based bluetooth connection manager.")
    (license license:gpl3)))
