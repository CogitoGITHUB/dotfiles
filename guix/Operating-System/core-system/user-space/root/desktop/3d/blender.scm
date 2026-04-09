(define-module (core-system user-space root desktop 3d blender)
  #:use-module (gnu packages graphics)
  #:use-module (guix packages)
  #:re-export (blender))

;; Re-export of blender from gnu/packages/graphics
;; This is a thin wrapper that re-exports the upstream package
