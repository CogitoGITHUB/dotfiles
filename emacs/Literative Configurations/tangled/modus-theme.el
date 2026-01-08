;;; -*- lexical-binding: t -*-

(setq modus-themes-bold-constructs t
modus-themes-italic-constructs t
modus-themes-org-blocks 'gray-background
modus-themes-fringes 'intense
modus-themes-mode-line '(borderless))

(load-theme 'modus-operandi :no-confirm)

(defun shapeshift/grey-world ()
"Pure grey-on-grey monochrome for everything."

;; Canvas
(set-face-attribute 'default nil
:foreground "#000000"
:background "#e0e0e0")
(set-face-attribute 'fringe nil
:background "#e0e0e0"
:foreground "#000000")

;; Org hierarchy
(dolist (level '(org-document-title org-level-1 org-level-2 org-level-3
org-level-4 org-level-5 org-level-6 org-level-7 org-level-8))
(set-face-attribute level nil
:foreground "#000000"
:weight 'bold
:inherit nil))
(set-face-attribute 'org-document-title nil :height 2.0)
(set-face-attribute 'org-level-1 nil :height 1.8)
(set-face-attribute 'org-level-2 nil :height 1.6)
(set-face-attribute 'org-level-3 nil :height 1.4)
(set-face-attribute 'org-level-4 nil :height 1.2)

;; Org elements
(dolist (face '(org-link org-block org-block-begin-line org-block-end-line
org-code org-verbatim org-meta-line org-todo org-done))
(set-face-attribute face nil
:foreground "#000000"
:background "#dcdcdc"
:weight 'bold
:inherit nil))

;; Code syntax highlighting
(dolist (face '(font-lock-comment-face
font-lock-string-face
font-lock-keyword-face
font-lock-function-name-face
font-lock-variable-name-face
font-lock-type-face
font-lock-constant-face
font-lock-builtin-face
font-lock-warning-face
font-lock-doc-face))
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:inherit nil))

;; LaTeX faces
(with-eval-after-load 'tex-mode
(dolist (face '(font-latex-math-face
font-latex-script-char-face
font-latex-string-face
font-latex-warning-face
font-latex-sedate-face
font-latex-sectioning-0-face
font-latex-sectioning-1-face
font-latex-sectioning-2-face
font-latex-sectioning-3-face
font-latex-sectioning-4-face
font-latex-sectioning-5-face))
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:inherit nil)))

;; Dired
(with-eval-after-load 'dired
(dolist (face '(dired-directory
dired-symlink
dired-mark
dired-marked
dired-flagged
dired-warning
dired-perm-write
dired-special
dired-header
dired-ignored))
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:weight 'bold
:inherit nil)))

;; Magit
(with-eval-after-load 'magit
(dolist (face '(magit-section-heading
magit-section-highlight
magit-branch-local
magit-branch-remote
magit-branch-current
magit-hash
magit-tag
magit-diff-added
magit-diff-removed
magit-diff-added-highlight
magit-diff-removed-highlight
magit-diff-context
magit-diff-context-highlight
magit-diff-hunk-heading
magit-diff-hunk-heading-highlight
magit-diff-file-heading
magit-diff-file-heading-highlight
magit-log-author
magit-log-date
magit-log-graph
magit-process-ok
magit-process-ng
magit-signature-good
magit-signature-bad
magit-signature-untrusted
magit-cherry-equivalent
magit-cherry-unmatched))
(when (facep face)
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:inherit nil))))

;; PDF-tools
(with-eval-after-load 'pdf-view
(setq pdf-view-midnight-colors '("#000000" . "#e0e0e0")))

;; Line numbers
(when (facep 'line-number)
(set-face-attribute 'line-number nil
:foreground "#000000"
:background "#e0e0e0")
(set-face-attribute 'line-number-current-line nil
:foreground "#000000"
:background "#dcdcdc"
:weight 'bold))

;; Highlighting
(with-eval-after-load 'hl-line
(set-face-attribute 'hl-line nil
:background "#dcdcdc"
:inherit nil))
(set-face-attribute 'region nil
:background "#cfcfcf"
:foreground "#000000")
(set-face-attribute 'highlight nil
:background "#cfcfcf"
:foreground "#000000")

;; Minibuffer
(dolist (face '(minibuffer-prompt completions-annotations completions-common-part
completions-first-difference shadow help-key-binding))
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:weight 'bold
:inherit nil))

(when (facep 'completions-highlight)
(set-face-attribute 'completions-highlight nil
:foreground "#000000"
:background "#dcdcdc"
:inherit nil))

;; Vertico
(with-eval-after-load 'vertico
(dolist (face '(vertico-current vertico-group-title vertico-group-separator vertico-multiline))
(when (facep face)
(set-face-attribute face nil
:foreground "#000000"
:background "#dcdcdc"
:inherit nil))))

;; Orderless
(with-eval-after-load 'orderless
(dolist (face '(orderless-match-face-0 orderless-match-face-1
orderless-match-face-2 orderless-match-face-3))
(set-face-attribute face nil
:foreground "#000000"
:weight 'bold
:background "#e0e0e0"
:inherit nil)))

;; Ivy
(with-eval-after-load 'ivy
(dolist (face '(ivy-current-match
ivy-minibuffer-match-face-1
ivy-minibuffer-match-face-2
ivy-minibuffer-match-face-3
ivy-minibuffer-match-face-4
ivy-action
ivy-highlight-face
ivy-remote
ivy-subdir
ivy-virtual
ivy-confirm-face
ivy-match-required-face))
(when (facep face)
(set-face-attribute face nil
:foreground "#000000"
:weight 'bold
:background "#e0e0e0"
:inherit nil))))

;; Helm
(with-eval-after-load 'helm
(dolist (face '(helm-selection helm-match helm-source-header helm-visible-mark
helm-candidate-number helm-separator helm-M-x-key
helm-buffer-directory helm-buffer-file helm-buffer-process
helm-ff-directory helm-ff-file helm-grep-match))
(when (facep face)
(set-face-attribute face nil
:foreground "#000000"
:background "#e0e0e0"
:weight 'bold
:inherit nil)))))

;; Apply immediately
(shapeshift/grey-world)

;; Persist after theme reload
(advice-add 'load-theme :after
(lambda (&rest _) (shapeshift/grey-world)))

;; Apply after making frames
(add-hook 'after-make-frame-functions
(lambda (_frame) (shapeshift/grey-world)))
