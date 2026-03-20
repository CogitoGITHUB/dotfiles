;;;; Keyboard configuration
(use-modules (gnu system keyboard))

(define-public literativeos-keyboard-layout
  (keyboard-layout "us" "dvorak"
                   #:options '("caps:backspace")))
