
(define-module (shells atuin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))

(define %atuin-init-nu
  "
# Nushell init for Atuin
$env.ATUIN_SESSION = (atuin uuid)
hide-env -i ATUIN_HISTORY_ID

let ATUIN_KEYBINDING_TOKEN = \"# (random uuid)\"

let _atuin_pre_execution = {||
    if (nu | get -i history-enabled) == false { return }
    let cmd = (commandline)
    if (cmd | is-empty) { return }
    if not (cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
        $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
    }
}

let _atuin_pre_prompt = {||
    let last_exit = $env.LAST_EXIT_CODE
    if 'ATUIN_HISTORY_ID' not-in $env { return }
    with-env { ATUIN_LOG: error } {
        do { atuin history end --exit=$last_exit -- $env.ATUIN_HISTORY_ID } | complete
    }
    hide-env ATUIN_HISTORY_ID
}

# Register the hook
$env.config.pre_EXEC = $env.config.pre_EXEC ++ $_atuin_pre_execution
$env.config.pre_prompt = $env.config.pre_prompt ++ $_atuin_pre_prompt
")

(define-public atuin
  (package
    (name "atuin")
    (version "18.2.0")
    (synopsis "Magical shell history with SQLite backend")
    (description "Atuin replaces your existing shell history with a SQLite database")
    (home-page "https://github.com/atuinsh/atuin")
    (license license:expat)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/atuinsh/atuin/releases/download/v" version "/atuin-v" version "-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "04s3apdb80d4dsa5aklzw1bwq9zd7s67pxkdq6mwbbvn7ymdlf6h"))
       (file-name (string-append "atuin-" version ".tar.gz"))))
    (build-system copy-build-system)
    (arguments
      (list #:install-plan
            (list
              (list "bin/atuin" "bin/atuin")
              (list (plain-file "init.nu" %atuin-init-nu) "share/atuin/init.nu"))))))
