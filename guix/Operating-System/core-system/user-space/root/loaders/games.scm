(define-module (core-system user-space root loaders games)
  #:use-module (core-system user-space root games retroarch)
  #:re-export (retroarch retroarch-assets retroarch-joypad-autoconfig)
  #:export (root-games-packages))

(define-public root-games-packages
  (list retroarch retroarch-assets retroarch-joypad-autoconfig))
