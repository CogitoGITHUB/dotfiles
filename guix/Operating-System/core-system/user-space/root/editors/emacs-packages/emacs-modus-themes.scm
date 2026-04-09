(define-module (core-system user-space root editors emacs-packages emacs-modus-themes)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages texlive)
  #:use-module (gnu packages texinfo)
  #:export (emacs-modus-themes))

(define-public emacs-modus-themes
  (package
    (name "emacs-modus-themes")
    (version "5.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/protesilaos/modus-themes")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1iqbi71h9xajsw4330157dfs10npfi1z2ads99vr7n5pll7060rc"))))
    (build-system emacs-build-system)
    (native-inputs (list texinfo))
    (home-page "https://protesilaos.com/modus-themes/")
    (synopsis "Accessible themes for Emacs (WCAG AAA standard)")
    (description "The Modus themes are designed for accessible readability. They conform with the highest standard for color contrast.")
    (license license:gpl3+)))
