(define-module (core-system user-space root loaders 3d)
  #:use-module (core-system user-space root desktop 3d blender)
  #:re-export (blender)
  #:export (root-desktop-3d-packages))

(define-public root-desktop-3d-packages
  (list blender))
