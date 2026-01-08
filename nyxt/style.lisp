(in-package #:nyxt-user)

;; This sets the GTK theme to light for light interfaces.
(setf (uiop:getenv "GTK_THEME") "Adwaita")

(define-configuration browser
  ((theme theme:+light-theme+)))

(define-configuration :dark-mode
  "Dark-mode is a simple mode for simple HTML pages to color those in a darker palette.

I don't like the default gray-ish colors, though. Thus, I'm overriding
those to be a bit more laconia-like.

I'm not using this mode, though: I have nx-dark-reader."
   ((style
     (theme:themed-css (theme *browser*)
       `(*
         :background-color ,theme:background
         "!important"
         :background-image none "!important"
         :color ,theme:on-background
         "!important")
       `(a
         :background-color ,theme:background
         "!important"
         :background-image none "!important"
         :color ,theme:primary "!important")
       `("::selection"
         :background-color "blue" !important
         :color "white" !important)))))
