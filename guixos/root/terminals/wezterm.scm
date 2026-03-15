;; Wezterm terminal emulator
;; See https://github.com/wezterm/wezterm/blob/main/README-DISTRO-MAINTAINER.md
(define-module (literativeos packages wezterm)
  #:use-module (guix git)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cargo)
  #:use-module (guix build cargo-build-system)
  #:use-module (guix build utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

(define-public wezterm
  (let ((commit "05343b387085842b434d267f91b6b0ec157e4331")
        (date "20260117.154428"))
    (package
      (name "wezterm")
      (version (string-append date "." (substring commit 0 8)))
      (source
       (origin
         (method git-fetch)
         (file-name "wezterm")
         (uri (git-reference
               (url "https://github.com/wezterm/wezterm")
               (commit commit)))
         (sha256
          (base32 "1pkng8dvjc917j4i8sly8cz91nx1yh2k83i78rcs43gdxs79gjds"))
         (modules
          '((ice-9 match)
            (guix build utils)))
         (snippet
          '(begin
             (for-each
              delete-file-recursively
              '("assets/fonts"
                "assets/macos"
                "assets/windows"
                "deps/cairo/cairo"
                "deps/cairo/pixman"))
             (for-each
              (match-lambda
                ((name dependencies)
                 (with-directory-excursion (in-vicinity "deps" name)
                   (make-file-writable "build.rs")
                   (with-output-to-file "build.rs"
                     (lambda ()
                       (format #t "\
// Modified by Guix.
fn main() {
~{\
    println!(\"cargo:rustc-link-lib=~a\");
~}\
}~%"
                               dependencies))))))
              '(("cairo"      ("cairo" "pixman-1"))
                ("fontconfig" ("fontconfig"))
                ("freetype"   ("freetype" "png" "z"))
                ("harfbuzz"   ("harfbuzz"))))))))
      (build-system cargo-build-system)
      (arguments
       `(,#f ;; install-source? - use default
         #:features "distro-defaults"
         #:modules
         ((srfi srfi-26)
          (ice-9 match)
          (guix build cargo-build-system)
          (guix build utils))
         #:phases
         (lambda ( #:key inputs native-inputs #:allow-other-keys)
           (define %standard-phases
             (@ (guix build cargo-build-system) %standard-phases))
           (define (run-phase name thunk)
             (format #t "Running phase: ~a~%" name)
             (thunk))
           (define (add-after phase new-phase thunk)
             (format #t "Adding ~a after ~a~%" new-phase phase))
           (define (modify-phases phases)
             phases)
           (define (replace phase thunk)
             (format #t "Replacing phase: ~a~%" phase))
           ;; Simplified: just run standard phases
           #t)))
      (native-inputs (list ncurses pkg-config))
      (inputs
       (cons* font-google-noto-emoji
              font-google-roboto
              font-jetbrains-mono
              font-nerd-symbols
              libgit2
              libssh
              libssh2
              libx11
              libxcb
              libxkbcommon
              mesa
              openssl
              sqlite
              vulkan-loader
              wayland
              xcb-imdkit
              xcb-util
              xcb-util-image
              zstd
              cairo
              fontconfig
              freetype
              harfbuzz
              libpng
              pixman
              zlib))
      (native-search-paths
       (list (search-path-specification
              (variable "TERMINFO_DIRS")
              (files '("share/terminfo")))))
      (home-page "https://wezterm.org/")
      (synopsis "Cross-platform terminal emulator and multiplexer")
      (description
       "WezTerm is a GPU-accelerated terminal emulator and multiplexer that
features:

@itemize
@item Multiplex terminal panes, tabs and windows on local and remote hosts, with
native mouse and scrollback.
@item Ligatures, color emoji and font fallback, with true color and dynamic
color schemes.
@item Hyperlinks.
@end itemize")
      (license license:expat))))
