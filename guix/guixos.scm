(add-to-load-path "/home/aoeu/.config/guix/Operating-System")

(use-modules (core-system core-system))

(operating-system
  (inherit os)
  (services (operating-system-user-services os)))
