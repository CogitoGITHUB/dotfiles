(define-module (core-system user-space root editors emacs-packages org-mcp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (core-system user-space root editors emacs-packages mcp-server-lib)
  #:export (emacs-org-mcp))

(define-public emacs-org-mcp
  (package
    (name "emacs-org-mcp")
    (version "0.9.0-1.a443b5b")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/laurynas-biveinis/org-mcp/archive/"
              "a443b5b.tar.gz"))
        (sha256
         (base32 "1px6m4x509cjarhxk4whk69095rb87y5lmq80g3anghqghwzvcb3"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-mcp-server-lib))
    (home-page "https://github.com/laurynas-biveinis/org-mcp")
    (synopsis "MCP server for Org-mode")
    (description
     "org-mcp is an Emacs package that implements a Model Context Protocol (MCP)
server for Org-mode.  It enables AI assistants and other MCP clients to interact
with your Org files through a structured API, providing access to file contents,
outlines, and headline operations.")
    (license license:gpl3+)))
