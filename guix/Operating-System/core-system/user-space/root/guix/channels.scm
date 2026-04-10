(define-module (core-system user-space root guix channels)
  #:use-module (guix channels)
  #:export (system-channels))

(define-public system-channels
  (list
    (channel
      (name 'guix)
      (url "https://git.guix.gnu.org/guix.git")
      (branch "master"))
    (channel
      (name 'nonguix)
      (url "https://gitlab.com/nonguix/nonguix")
      (branch "master"))
    (channel
      (name 'literativeos)
      (url "file:///home/aoeu/.config/guix")
      (branch "main"))))
