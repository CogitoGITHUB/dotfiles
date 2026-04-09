(define-module (core-system user-space root editors emacs-packages emacs-mcp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages emacs-xyz)
  #:export (emacs-mcp))

(define-public emacs-mcp
  (let ((commit "4708c5849ce4ddb632016eca662a7405bfa642d4")
        (revision "0"))
    (package
      (name "emacs-mcp")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/lizqwerscott/mcp.el/")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "11x3jscm4iggyy926aidiv95lrbcncngbvivsybvzjvbhdxhb65h"))))
      (build-system emacs-build-system)
      (arguments '(#:tests? #f))
      (inputs (list emacs-jsonrpc))
      (home-page "https://github.com/lizqwerscott/mcp.el/")
      (synopsis "Emacs interface to MCP protocol")
      (description "emacs-mcp is an Emacs client providing structured communication to MCP servers.")
      (license license:gpl3+))))
