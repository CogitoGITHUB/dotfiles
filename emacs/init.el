;;; init.el --- STATIC SEED: tangles + loads Manifolding-Emacs-Foundation -*- lexical-binding: t -*-
;;
;; ┌─────────────────────────────────────────────────────────────┐
;; │  THIS FILE IS STATIC.  Never add configuration here.        │
;; │                                                             │
;; │  Single source of truth:                                    │
;; │    Manifolding-Emacs/Manifolding-Emacs-Foundation.org       │
;; │      · auto-tangled on save   (org-auto-tangle)             │
;; │      · re-tangled at startup  (below)                       │
;; │      → produces early-init.el + foundation-init.el          │
;; └─────────────────────────────────────────────────────────────┘

(setq debug-on-error t)

(let ((org-build (locate-user-emacs-file "straight/build/org")))
  (when (file-directory-p org-build)
    (add-to-list 'load-path org-build)))

(require 'org)

(defun manifold/home-candidates ()
  "Dirs to search for the vault: home plus physical parents behind symlinks.
Covers container homes (~=/root) whose real tree lives elsewhere."
  (let ((home (expand-file-name "~"))
        (out nil))
    (push home out)
    (dolist (e (ignore-errors (directory-files home t "^[^.]")))
      (when (and (file-symlink-p e)
                 (file-directory-p e))
        (let ((parent (file-name-directory
                       (directory-file-name (file-truename e)))))
          (when (and parent (file-directory-p parent))
            (push parent out)))))
    (delete-dups out)))

(defun manifold/scan-home-for-foundation ()
  "Search home candidates' children for the vault: the child containing .git/.
Structural match only: no vault name literal, renames never break it."
  (catch 'found
    (dolist (home (manifold/home-candidates))
      (dolist (top (ignore-errors (directory-files home t "^[^.]")))
        (when (and (file-directory-p top)
                   (file-directory-p (expand-file-name ".git" top)))
          (let ((hits (ignore-errors
                        (directory-files-recursively
                         top "Manifolding-Emacs-Foundation$" nil))))
            (when hits (throw 'found (car hits)))))))
    nil))

(defun manifold/find-foundation-org ()
  "Locate Manifolding-Emacs-Foundation by search, not fixed path.
Marker file first (instant), sibling dir next (old layout, instant),
then home-children scan.  Accepts extensionless and legacy .org names."
  (or (manifold/read-foundation-marker)
      (let ((found
             (or (let ((sib (locate-user-emacs-file
                             "Manifolding-Emacs/Manifolding-Emacs-Foundation")))
                   (when (file-exists-p sib) sib))
                 (let ((sib-org (locate-user-emacs-file
                                 "Manifolding-Emacs/Manifolding-Emacs-Foundation.org")))
                   (when (file-exists-p sib-org) sib-org))
                 (manifold/scan-home-for-foundation))))
        (when found (manifold/write-foundation-marker found))
        found)))

(defvar manifold--foundation-marker
  (locate-user-emacs-file ".foundation-path")
  "Marker file remembering where the Foundation source was found.
Avoids a full home-tree walk on every boot; the recorded path is
validated by existence before use, falling back to a scan.")

(defun manifold/read-foundation-marker ()
  "Foundation path from the marker file, or nil when stale/missing."
  (when (file-exists-p manifold--foundation-marker)
    (let ((p (with-temp-buffer
               (insert-file-contents manifold--foundation-marker)
               (buffer-string))))
      (setq p (replace-regexp-in-string "\\`[ \t\n]*\\|[ \t\n]*\\'" "" p))
      (when (and (stringp p) (not (string= p "")) (file-exists-p p))
        p))))

(defun manifold/write-foundation-marker (path)
  "Remember PATH as the Foundation source.  Never throws."
  (condition-case nil
      (with-temp-file manifold--foundation-marker (insert path))
    (error nil)))

(defvar manifold--foundation-org (manifold/find-foundation-org))
;; Tangled artifacts live in ~/.config/emacs (never in the vault).
(defvar manifold--foundation-init
  (locate-user-emacs-file "foundation-init.el"))

;; Extensionless vault sources must visit in org-mode: Org's own parser
;; warns (org-element-at-point in fundamental-mode) otherwise.
;; Scoped to the two tangled sources; recomputed every boot.
(let ((dir (and manifold--foundation-org
                (file-name-directory manifold--foundation-org))))
  (dolist (f (delq nil
                   (list manifold--foundation-org
                         (and dir (expand-file-name "manifolding-emacs" dir))
                         (and dir (expand-file-name "manifolding-emacs.org" dir)))))
    (add-to-list 'auto-mode-alist
                 `(,(concat "\\`" (regexp-quote f) "\\'") . org-mode))))

(defun manifold/tangle-foundation ()
  "Tangle the foundation.  Uses only built-in Org — no deps."
  (require 'ob-core)
  (org-babel-tangle-file manifold--foundation-org))

(defun manifold/foundation-tangle-needed-p ()
  "Non-nil when the Foundation source is newer than its artifacts.
Skips the startup re-tangle when a previous save/boot already
generated up-to-date early-init.el + foundation-init.el."
  (let ((early (locate-user-emacs-file "early-init.el")))
    (or (not (file-exists-p manifold--foundation-init))
        (not (file-exists-p early))
        (file-newer-than-file-p manifold--foundation-org
                                manifold--foundation-init)
        (file-newer-than-file-p manifold--foundation-org early))))

;; Startup tangle — belt and suspenders alongside org-auto-tangle.
;; Guarded: with explicit sync allowed, re-tangling every boot is pure
;; waste when the artifacts are already newer than the source.
(if (file-exists-p manifold--foundation-org)
    (when (manifold/foundation-tangle-needed-p)
      (with-demoted-errors "[foundation] startup tangle failed: %s"
        (manifold/tangle-foundation)))
  (message "[foundation] %s missing; using last generated config"
           (file-name-nondirectory manifold--foundation-org)))

;; Load the freshly generated (or last known good) configuration.
(if (file-exists-p manifold--foundation-init)
    (load manifold--foundation-init nil 'nomessage)
  (warn "[foundation] %s not found — bare editor this session"
        manifold--foundation-init))

;;; init.el ends here