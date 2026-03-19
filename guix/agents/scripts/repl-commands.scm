;;;; LiterativeOS Guile REPL Commands
;;;; Load this in REPL: ,l agents/scripts/repl-commands.scm

;;;; Aliases for quick operations

;; Load a package module and test it
;; Usage: (load-pkg "/path/to/package.scm")
(define (load-pkg path)
  (load path)
  (display (string-append "Loaded: " path "\n")))

;; Build a package (returns derivation)
;; Usage: (build-pkg "/path/to/package.scm")
(define (build-pkg path)
  (let ((pkg (load path)))
    (display "Building package...\n")
    pkg))

;; Search for package in guix
;; Usage: (search-pkg "curl")
(define (search-pkg name)
  (system* "guix" "package" "-A" name))

;; Get hash of a downloaded file
;; Usage: (get-hash "/tmp/file.tar.gz")
(define (get-hash file)
  (let* ((proc (open-input-pipe "guix hash"))
         (hash (get-string-all proc)))
    (close-pipe proc)
    (string-trim hash)))

;; Print current system generations
(define (generations)
  (system* "guix" "system" "list-generations"))

;; Quick rebuild test - just build system, don't activate
(define (sys-build)
  (system* "guix" "system" "build" "/home/aoeu/.config/guix/config.scm"))

;; Print helpful info
(define (help)
  (display "
LiterativeOS REPL Commands:
- (load-pkg \"path\")    - Load and test a package module
- (build-pkg \"path\")   - Build a package
- (search-pkg \"name\")  - Search packages
- (get-hash \"file\")    - Get guix hash of file
- (generations)         - List system generations
- (sys-build)          - Build system (no activate)
- (help)               - This help
"))

(display "LiterativeOS REPL commands loaded. Type (help) for list.\n")