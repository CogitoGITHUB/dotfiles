(define-module (core-system user-space root desktop wayscriber)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (wayscriber))

(define-public wayscriber
  (package
    (name "wayscriber")
    (version "0.9.13")
    (source
     (origin
       (method url-fetch)
       (uri "file:///tmp/wayscriber-build/target/release/wayscriber")
       (sha256
        (base32 "04sr64dswc0vql7bas0aj0z2h9ipm491frg04cjk38w59giazxcs"))))
    (build-system trivial-build-system)
    (inputs (list gtk
                  libxkbcommon
                  cairo
                  pango
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
                 (copy-file src (string-append bin "/wayscriber"))
                 (chmod (string-append bin "/wayscriber") #o755)))))
    (home-page "https://wayscriber.com")
    (synopsis "Screen annotation tool for Wayland compositors")
    (description
     "Wayscriber is a ZoomIt-like screen annotation tool for Linux Wayland
compositors.  It provides drawing tools (freehand, lines, rectangles,
ellipses, arrows, text, sticky notes, highlighter, eraser), board modes
(whiteboard, blackboard, transparent overlay), presets, zoom, and system
tray integration.  Works on Hyprland, Sway, River, GNOME, KDE, and other
wlr-layer-shell compositors.")
    (license license:expat)))
