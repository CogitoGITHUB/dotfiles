;;; -*- lexical-binding: t -*-

(setq evil-want-keybinding nil
      evil-want-C-u-scroll t)

(evil-mode 1)

;; ════════════════════════════════════════════════════════════
;; § DVORAK HTNS — DIRECTIONAL DISCIPLINE
;; ════════════════════════════════════════════════════════════
;; h = left, t = down, n = up, s = right
(define-key evil-normal-state-map (kbd "h") 'evil-backward-char)
(define-key evil-normal-state-map (kbd "t") 'evil-next-line)
(define-key evil-normal-state-map (kbd "n") 'evil-previous-line)
(define-key evil-normal-state-map (kbd "s") 'evil-forward-char)
(define-key evil-motion-state-map (kbd "h") 'evil-backward-char)
(define-key evil-motion-state-map (kbd "t") 'evil-next-line)
(define-key evil-motion-state-map (kbd "n") 'evil-previous-line)
(define-key evil-motion-state-map (kbd "s") 'evil-forward-char)

;; Visual state movement
(define-key evil-visual-state-map (kbd "h") 'evil-backward-char)
(define-key evil-visual-state-map (kbd "t") 'evil-next-line)
(define-key evil-visual-state-map (kbd "n") 'evil-previous-line)
(define-key evil-visual-state-map (kbd "s") 'evil-forward-char)

;; Keep standard Evil delete behavior (dd, dw, etc. still work)
;; The 'd' key works as an operator in normal mode by default

;; ════════════════════════════════════════════════════════════
;; § LEADER KEY — SPACE AS COMMAND NEXUS
;; ════════════════════════════════════════════════════════════
(defvar shapeshifter-leader-map (make-sparse-keymap))
(define-key evil-normal-state-map (kbd "SPC") shapeshifter-leader-map)
(define-key evil-motion-state-map (kbd "SPC") shapeshifter-leader-map)

;; ════════════════════════════════════════════════════════════
;; § LEADER BINDINGS — CORE OPERATIONS
;; ════════════════════════════════════════════════════════════
(define-key shapeshifter-leader-map (kbd "f") #'find-file)
(define-key shapeshifter-leader-map (kbd "s") #'save-buffer)
(define-key shapeshifter-leader-map (kbd "g") #'magit-status)
(define-key shapeshifter-leader-map (kbd "b") #'switch-to-buffer)
(define-key shapeshifter-leader-map (kbd "k") #'kill-buffer)
(define-key shapeshifter-leader-map (kbd "j") #'avy-goto-char-timer)
;; Dired launcher
(define-key shapeshifter-leader-map (kbd "d") #'dired)
(define-key shapeshifter-leader-map (kbd "D") #'dired-jump) ; jump to current file's dir

;; Window navigation using SPC w prefix (standard evil convention)
(define-key shapeshifter-leader-map (kbd "w") (make-sparse-keymap))
(define-key shapeshifter-leader-map (kbd "wh") #'evil-window-left)
(define-key shapeshifter-leader-map (kbd "ws") #'evil-window-right)
(define-key shapeshifter-leader-map (kbd "wt") #'evil-window-down)
(define-key shapeshifter-leader-map (kbd "wn") #'evil-window-up)
(define-key shapeshifter-leader-map (kbd "ww") #'evil-window-next)
(define-key shapeshifter-leader-map (kbd "wv") #'evil-window-vsplit)
(define-key shapeshifter-leader-map (kbd "wx") #'evil-window-split)
(define-key shapeshifter-leader-map (kbd "wq") #'evil-window-delete)

;; ════════════════════════════════════════════════════════════
;; § ORG MODE — STRUCTURAL NAVIGATION
;; ════════════════════════════════════════════════════════════
(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map
    (kbd "TAB")       #'org-cycle
    (kbd "<tab>")     #'org-cycle
    (kbd "<C-tab>")   #'org-shifttab
    (kbd "C-<tab>")   #'org-shifttab))

;; ═══════════════════════════════════════
;; § GREASE — GLOBAL LAUNCHER
;; ═══════════════════════════════════════

;; Quick version: open directly in current buffer's directory
(defun shapeshifter/open-grease-here ()
  "Open Grease directly in the current buffer's directory."
  (interactive)
  (grease-open default-directory))

;; Prompt version: choose directory
(defun shapeshifter/open-grease-prompt ()
  "Prompt for a directory (default to current buffer) and open Grease there."
  (interactive)
  (let ((dir (read-directory-name "Open Grease in directory: " default-directory)))
    (grease-open dir)))

;; Bindings
(define-key shapeshifter-leader-map (kbd "x") #'shapeshifter/open-grease-here)
(define-key shapeshifter-leader-map (kbd "X") #'shapeshifter/open-grease-prompt)


;; ═══════════════════════════════════════
;; § GREASE — DVORAK-OPTIMIZED NAVIGATION & POWER
;; ═══════════════════════════════════════
(with-eval-after-load 'grease
  (evil-define-key 'normal grease-mode-map
    ;; ──────────────────────────────────────────────
    ;; Core Navigation (Dvorak HTNS)
    ;; ──────────────────────────────────────────────
    (kbd "h") #'grease-up-directory                     ; parent dir
    (kbd "s") #'grease-visit                             ; open file/dir
    (kbd "t") #'evil-next-line                           ; down
    (kbd "n") #'evil-previous-line                       ; up

    ;; ──────────────────────────────────────────────
    ;; Enhanced Actions
    ;; ──────────────────────────────────────────────
    (kbd "RET") #'grease-visit

    ;; ──────────────────────────────────────────────
    ;; Toggle / Misc Features
    ;; ──────────────────────────────────────────────
    (kbd ".") #'grease-toggle-hidden

    ;; ──────────────────────────────────────────────
    ;; Arrow keys
    ;; ──────────────────────────────────────────────
    (kbd "<left>") #'grease-up-directory
    (kbd "<right>") #'grease-visit
    (kbd "<up>") #'evil-previous-line
    (kbd "<down>") #'evil-next-line))


;; ════════════════════════════════════════════════════════════
;; § TAB BAR — ECHO-AREA CARTOGRAPHY
;; ════════════════════════════════════════════════════════════
(with-eval-after-load 'tab-bar-echo-area
;; Leader: SPC t …
(define-key shapeshifter-leader-map (kbd "t") (make-sparse-keymap))

;; SPC t c → echo current tab name
(define-key shapeshifter-leader-map (kbd "tc")
#'tab-bar-echo-area-print-tab-name)

;; SPC t p → echo all tab names
(define-key shapeshifter-leader-map (kbd "tp")
#'tab-bar-echo-area-print-tab-names))

(evil-collection-init)

(global-evil-surround-mode 1)

(declare-function web-mode-comment-or-uncomment-region "web-mode")
(setq evilnc-comment-text-object "c")
(evilnc-default-hotkeys)
(define-key evil-normal-state-map (kbd "gc") #'evilnc-comment-or-uncomment-lines)
(define-key evil-visual-state-map (kbd "gc") #'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map (kbd "gC") #'evilnc-copy-and-comment-lines)
