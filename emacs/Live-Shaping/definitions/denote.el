;; denote.el --- Live-Shaping Denote module -*- lexical-binding: t; -*-

;;; Commentary:
;; Denote integrated into the Live-Shaping architecture.

;;; Code:

(use-package denote
  :load-path (lambda ()
               (list (expand-file-name
                      "Live-Shaping/sources/denote"
                      user-emacs-directory)))
  :init
  ;; Base directory for all Live-Shaping notes
  (setq denote-directory (expand-file-name "~/Shapeless-Links"))

  ;; Default file type
  (setq denote-file-type 'org)

  ;; Keywords to classify notes, especially Emacs manual fragments
  (setq denote-known-keywords '("emacs" "manual" "lisp" "editing" "ui" "core"))

  ;; Sort keywords when creating notes
  (setq denote-sort-keywords t)

  :config
  ;; No extra modules required (modern Denote handles Org by default)
  )

(provide 'denote)
;;; denote.el ends here
