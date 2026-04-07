(define-module (core-system user-space root editors emacs-packages mcp-server-lib)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-mcp-server-lib))

(define-public emacs-mcp-server-lib
  (package
    (name "emacs-mcp-server-lib")
    (version "0.2.0-1.838b5f9")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/laurynas-biveinis/mcp-server-lib.el/archive/"
              "838b5f9.tar.gz"))
        (sha256
         (base32 "08dmcjqghgiys061rfyssr3bqc54a1rbbibpbqxhfcfas81azhha"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/laurynas-biveinis/mcp-server-lib.el")
    (synopsis "Emacs library for implementing MCP servers")
    (description
     "MCP Server Lib is an Emacs Lisp library that simplifies the implementation
of Model Context Protocol (MCP) servers within Emacs.  It provides utilities
for handling MCP protocol messages, managing connections, and implementing
tools and resources.")
    (license license:gpl3+)))
