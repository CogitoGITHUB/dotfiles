;;;; Curl HTTP client - Needed for downloading package hashes, checking GitHub releases
;;;; Why: AI needed curl to get atuin/starship hashes during package creation
(define-public curl
  (package
    (name "curl")
    (version "8.6.0")
    (synopsis "Command line tool for transferring data with URL syntax")
    (description "Curl is a command line tool for transferring data with URL syntax.")
    (home-page "https://curl.se")
    (license expat)
    (source #f)
    (build-system gnu-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (delete 'build)
                  (delete 'check)
                  (delete 'configure))))
    (inputs (list (module-ref (resolve-interface '(gnu packages tls)) 'openssl)
                 (module-ref (resolve-interface '(gnu packages libssh2)) 'libssh2)
                 (module-ref (resolve-interface '(gnu packages nghttp2)) 'nghttp2)
                 (module-ref (resolve-interface '(gnu packages compression)) 'zlib)))
    (native-inputs (list (module-ref (resolve-interface '(gnu packages build-tools)) 'pkg-config)))))