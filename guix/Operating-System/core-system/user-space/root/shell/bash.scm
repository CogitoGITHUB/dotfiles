(define-module (core-system user-space root shell bash)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages readline)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:export (bash))

(define (patch-url seqno)
  "Return the URL of Bash patch number SEQNO."
  (format #f "mirror://gnu/bash/bash-5.2-patches/bash52-~3,'0d" seqno))

(define (bash-patch seqno sha256-bv)
  "Return the origin of Bash patch SEQNO, with expected hash SHA256-BV."
  (origin
    (method url-fetch)
    (uri (patch-url seqno))
    (sha256 sha256-bv)))

(define-syntax-rule (patch-series (seqno hash) ...)
  (list (bash-patch seqno (base32 hash))
        ...))

(define %patch-series-5.2
  (patch-series
   (1 "02iibpd3jq8p1bhdzgik8ps6gi1145vr463a82gj1hivjbp2ybzl")
   (2 "1f6p1z85qh1lavdp3xikgp0bfv0vqhvgpgwmdzlywl35hwdmxk25")
   (3 "1zxsi869jd90hksx3nyypgyqwrxhw2ws3r6hmk76yc1lsgdhq2ba")
   (4 "04i5liw5cg6dqkdxfgazqc2jrw40bmclx3dx45bwy259pcj7g0iq")
   (5 "0mykflv9qnbx3jz71l4f7isadiw9knm4qimqkwsv9cv88dafpq7c")
   (6 "13265akl8w6zyrg0l7f0x6arjgqjhllcwl6lk46rl53x4mm5dq6i")
   (7 "146lrwkn5wgxzs6vx34wl47g69zsxdy032k40qzi626b47ya6015")
   (8 "1s5i8hcayrv25lc8fxcr431v634yx5sii53b8fmip789s0pxjjvb")
   (9 "1kfk25151ka9wkmk1myf12irgcmvhsd8b0nfifvhrszah9w82npr")
   (10 "1kf1jrwm30js0v3d1r2rk4x09s1pyjp70wnd1qqhf9bmkw15ww67")
   (11 "1x5nkvbj6hci7gx42q7qa72hg2a9wwxh85dk79gn521ypwjmy6w3")
   (12 "0b6lcwzm7v5bzjiwaz2c8n5aj77w8ckhp2vwk4v3zsdq3z70gc9g")
   (13 "1rkwpibd6j2ghppfhqsva2jm4kdni6b7jpdsxdps52643gc4yjq9")
   (14 "09766vqqw4ffnmysm725v35qkhp1g9j4qgqag941xvq655pj9y9y")
   (15 "12im449abnq5gaqjmdxr5i38kmp02fa8l8wffad3jryvd58r0wzg")
   (16 "05arb0hzmng03cr357lf6p8af0x2a1pznsd3psll03nibfy56n0m")
   (17 "129cvx4gfz8n23iw1lhbknbw86fyw6vh60jqj1wj3d5pr75wwj0w")
   (18 "105am94qxjc27gga4a8asvsi01090xwjfim3s16lafwjvm4xsha6")
   (19 "10njgv5mrc5rhsp5lvxcbm0pnzn59a8spi2nhdasifyl1a32cp1j")
   (20 "07f0wlmqjdfarp44w3gj9gdqbqm5x20rvlhpn34ngklmxcm2bz5n")
   (21 "1kahfqqalcwi4m73pg3ssz6lh0kcqsqax09myac7a15d2y0vhd43")
   (22 "0w74aym0g1fh48864a3qxh89f26iaq7wsbg7244c6kjr94527dbq")
   (23 "1lywjqbc36j5pdzfcvnz1zy30j76aqmsm190p888av0hw815b45g")
   (24 "1hq23djqbr7s9y2324jq9mxr5bwdkmgizn3zgpchbsqp054k85cp")
   (25 "0x9hc4silzl4d3zw4p43i5dm7w86k50j47f87lracwfgwy3z8f2i")
   (26 "1b1fhm1dsi67r8ip17s0xvx2qq31fsxc1g9n3r931dd0k9a1zvln")
   (27 "0fdbhvs9dkf4knncifh98a76q4gylhyvfrffq5p9q3ag5q58jap1")
   (28 "1hdacd6sssjshmry1sscdnxxfb2r51bvdyghlfjaqgc9l85phhk0")
   (29 "11wrlb20w6v89b96krg0gwxipwhvrda6rq1y9f972m32gsrsqp0j")
   (30 "13v9fqgim082dmvkslsr0hs793yzhsij2s91mjswsfhj1qip7zy3")
   (31 "15d7rddj6spwc1fy997lxx6zvzq0zbxgf2h20mhi4wgp5nzbglf2")
   (32 "05ia6yf32hjprmyyxqawhgckxs3684ikfx8xg08zfgx9xkd7g73v")
   (33 "1qm2aad9mf2xah6xwchga7s5pk3v308mrv9lgh50d65d236ccgh1")
   (34 "0bi38dhkkwpm2qrzp8zpykglq6gibvv2n9f8m59gwj406cxvp7w9")
   (35 "1r8k34y82v02yfkgws17j7i53ybb74dqnwl2jjiv0av9z93hl6l2")
   (36 "0mwhr9hfbh2czf8klbxg6nbd2g9xl9kygvgk061vird56r4kzj8m")
   (37 "156sbi3srzkyxajkmhb7iigq0j4nvwnpsbw88xdsxn95a4xiqb4a")))

(define-public bash
  (let* ((cppflags (string-join '("-DDEFAULT_PATH_VALUE='\"/no-such-path\"'"
                                  "-DSTANDARD_UTILS_PATH='\"/no-such-path\"'"
                                  "-DNON_INTERACTIVE_LOGIN_SHELLS"
                                  "-DSSH_SOURCE_BASHRC"
                                  "-DSYS_BASHRC='\"/etc/bashrc\"'")
                                " "))
         (configure-flags
          ``("--without-bash-malloc"
             "--with-installed-readline"
             ,,(string-append "CPPFLAGS=" cppflags)
             ,(string-append
               "LDFLAGS=-Wl,-rpath -Wl,"
               (assoc-ref %build-inputs "readline")
               "/lib"
               " -Wl,-rpath -Wl,"
               (assoc-ref %build-inputs "ncurses")
               "/lib")))
         (version "5.2"))
    (package
      (name "bash")
      (source (origin
                (method url-fetch)
                (uri (string-append
                      "mirror://gnu/bash/bash-" version ".tar.gz"))
                (sha256
                 (base32
                  "1yrjmf0mqg2q8pqphjlark0mcmgf88b0acq7bqf4gx3zvxkc2fd1"))
                (patch-flags '("-p0"))
                (patches (cons (search-patch "bash-linux-pgrp-pipe.patch")
                               %patch-series-5.2))))
      (version (string-append version "." (number->string (length %patch-series-5.2))))
      (build-system gnu-build-system)
      (outputs '("out" "doc" "include"))
      (inputs (list readline ncurses))
      (arguments
       `(;; When cross-compiling, `configure' incorrectly guesses that job
         ;; control is missing.
         #:configure-flags ,(if (%current-target-system)
                                `(cons* "bash_cv_job_control_missing=no"
                                        ,configure-flags)
                                configure-flags)
         #:parallel-build? #f
         #:parallel-tests? #f
         #:tests? #f
         #:modules ((srfi srfi-26)
                    (guix build utils)
                    (guix build gnu-build-system))
         #:phases
         (modify-phases %standard-phases
           (add-after 'install 'install-sh-symlink
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((out (assoc-ref outputs "out")))
                 (with-directory-excursion (string-append out "/bin")
                   (symlink "bash" "sh")
                   #t))))
           (add-after 'install 'move-development-files
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((out     (assoc-ref outputs "out"))
                     (include (assoc-ref outputs "include"))
                     (lib     (cut string-append <> "/lib/bash")))
                 (mkdir-p (lib include))
                 (rename-file (string-append (lib out)
                                             "/Makefile.inc")
                              (string-append (lib include)
                                             "/Makefile.inc"))
                 (rename-file (string-append out "/lib/pkgconfig")
                              (string-append include
                                             "/lib/pkgconfig"))
                 (substitute* (string-append (lib include)
                                             "/Makefile.inc")
                   (("^INSTALL =.*")
                    "INSTALL = install -c\n"))
                 #t))))))
      (native-search-paths
       (list (search-path-specification
              (variable "BASH_LOADABLES_PATH")
              (files '("lib/bash")))))
      (synopsis "The GNU Bourne-Again SHell")
      (description
       "Bash is the shell, or command-line interpreter, of the GNU system.  It
is compatible with the Bourne Shell, but it also integrates useful features
from the Korn Shell and the C Shell and new improvements of its own.  It
allows command-line editing, unlimited command history, shell functions and
aliases, and job control while still allowing most sh scripts to be run
without modification.")
      (license license:gpl3+)
      (home-page "https://www.gnu.org/software/bash/"))))
