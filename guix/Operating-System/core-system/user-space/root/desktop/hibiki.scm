(define-module (core-system user-space root desktop hibiki)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (hibiki))

(define-public hibiki
  (package
    (name "hibiki")
    (version "0.1.5")
    (source
     (origin
       (method url-fetch)
       (uri "file:///home/aoeu/.local/share/guix-binaries/hibiki")
       (sha256
        (base32 "08krjb0xdp2wnjnjqimk41hszhsba7f64vm2np3f09s1n10r3hgf"))))
    (build-system trivial-build-system)
    (inputs (list gtk
                  gtk4-layer-shell
                  alsa-lib
                  jack-2
                  fontconfig
                  libxkbcommon
                  dbus
                  coreutils))
    (arguments
     (list #:modules '((guix build utils))
           #:builder
           #~(begin
               (use-modules (guix build utils))
               (let* ((out  (assoc-ref %outputs "out"))
                      (bin  (string-append out "/bin"))
                      (src  (assoc-ref %build-inputs "source")))
                 (mkdir-p bin)
                 (copy-file src (string-append bin "/hibiki"))
                 (chmod (string-append bin "/hibiki") #o755)))))
    (home-page "https://github.com/linuxmobile/hibiki")
    (synopsis "GTK4 Layer Shell keystroke visualizer for Wayland")
    (description
     "Hibiki is a high-fidelity visual and auditory companion that gives
your keystrokes a modern resonance.  Built with GTK4 and Layer Shell
for Wayland compositors, it features keystroke and bubble display modes,
a native audio engine, and system tray integration.")
    (license license:expat)))
