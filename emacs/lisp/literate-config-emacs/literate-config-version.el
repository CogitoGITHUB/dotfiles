;;; literate-config-version.el --- Version enforcement system -*- lexical-binding: t -*-

;; Copyright (C) 2025
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:
;; Version tracking and enforcement for literate package configurations.
;; Supports universal git hosting (GitHub, GitLab, Codeberg, custom servers).

;;; Code:

(require 'cl-lib)

;; ════════════════════════════════════════════════════════════════════
;; § VERSION DETECTION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-version--get-installed (package-name)
  "Get installed version for PACKAGE-NAME from straight.el git repo.
Works with any git remote (GitHub, GitLab, Gitea, Codeberg, etc.)."
  (let* ((repo-dir (straight--repos-dir package-name)))
    (when (and repo-dir (file-exists-p repo-dir))
      (let ((default-directory repo-dir))
        ;; Try to get latest git tag (works for any git remote)
        (let ((version (string-trim
                        (shell-command-to-string 
                         "git describe --tags --abbrev=0 2>/dev/null"))))
          (if (string-empty-p version)
              ;; No tags found, use short commit hash
              (string-trim (shell-command-to-string "git rev-parse --short HEAD"))
            version))))))

(defun literate-config-version--fetch-latest-from-git (repo-url)
  "Fetch latest tag from any git REPO-URL (GitHub, GitLab, Codeberg, etc.)."
  (condition-case err
      (let* ((output (shell-command-to-string 
                      (format "git ls-remote --tags --sort=-version:refname %s 2>/dev/null" repo-url)))
             (lines (split-string output "\n" t)))
        ;; Parse first tag (most recent by version sort)
        (when lines
          (when (string-match "refs/tags/\\(.+\\)\\^{}$\\|refs/tags/\\(.+\\)$" (car lines))
            (or (match-string 1 (car lines))
                (match-string 2 (car lines))))))
    (error
     (message "Failed to fetch git tags: %s" (error-message-string err))
     nil)))

(defun literate-config-version--parse-repo-url (straight-spec)
  "Extract git URL from STRAIGHT-SPEC."
  (when straight-spec
    (cond
     ;; GitHub: :repo "user/repo"
     ((string-match ":repo\\s-+\"\\([^/]+/[^\"]+\\)\"" straight-spec)
      (if (string-match ":host\\s-+github" straight-spec)
          (format "https://github.com/%s" (match-string 1 straight-spec))
        ;; Assume GitHub if no host specified
        (format "https://github.com/%s" (match-string 1 straight-spec))))
     
     ;; GitLab
     ((string-match ":host\\s-+gitlab.*:repo\\s-+\"\\([^\"]+\\)\"" straight-spec)
      (format "https://gitlab.com/%s" (match-string 1 straight-spec)))
     
     ;; Codeberg
     ((string-match ":host\\s-+codeberg.*:repo\\s-+\"\\([^\"]+\\)\"" straight-spec)
      (format "https://codeberg.org/%s" (match-string 1 straight-spec)))
     
     ;; Direct :url
     ((string-match ":url\\s-+\"\\([^\"]+\\)\"" straight-spec)
      (match-string 1 straight-spec))
     
     ;; Can't parse - return nil
     (t nil))))

;; ════════════════════════════════════════════════════════════════════
;; § VERSION COMPARISON
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-version--parse (version-string)
  "Parse VERSION-STRING like 'v1.15.0' into (1 15 0)."
  (when (and version-string (string-match "^v?\\([0-9]+\\)\\.\\([0-9]+\\)\\.\\([0-9]+\\)" version-string))
    (list (string-to-number (match-string 1 version-string))
          (string-to-number (match-string 2 version-string))
          (string-to-number (match-string 3 version-string)))))

(defun literate-config-version--compare (v1 v2)
  "Compare versions V1 and V2. Returns 'equal, 'less, 'greater, or 'incomparable."
  (let ((parsed-v1 (literate-config-version--parse v1))
        (parsed-v2 (literate-config-version--parse v2)))
    (cond
     ;; Both are semantic versions - compare numerically
     ((and parsed-v1 parsed-v2)
      (cond ((equal parsed-v1 parsed-v2) 'equal)
            ((version-list-< parsed-v1 parsed-v2) 'less)
            (t 'greater)))
     
     ;; At least one is not semantic (commit hash) - string equality only
     ((string= v1 v2) 'equal)
     
     ;; Different non-semantic versions - can't compare
     (t 'incomparable))))

;; ════════════════════════════════════════════════════════════════════
;; § VERSION CHECKING
;; ════════════════════════════════════════════════════════════════════

(defvar literate-config-version--mismatch-handler nil
  "Handler function for version mismatches. Set by dashboard on startup.")

(defun literate-config-version-check-and-handle (package-name props file)
  "Check version for PACKAGE-NAME with PROPS from FILE.
Throws error on mismatch if enforcement is enabled."
  (let* ((config-version (plist-get props :version))
         (installed-version (literate-config-version--get-installed package-name)))
    
    (unless installed-version
      (message "Warning: Cannot detect installed version for %s" package-name)
      (return))
    
    (let ((comparison (literate-config-version--compare config-version installed-version)))
      (pcase comparison
        ('equal
         ;; Versions match - all good
         nil)
        
        ('less
         ;; Config is older - ERROR or prompt
         (literate-config-version--handle-mismatch 
          package-name config-version installed-version file))
        
        ('greater
         ;; Config is newer - WARN
         (message "Warning: Config version %s is NEWER than installed %s for %s" 
                  config-version installed-version package-name))
        
        ('incomparable
         ;; Can't compare (commit hashes) - WARN but allow
         (message "Info: Cannot compare versions for %s: config=%s installed=%s" 
                  package-name config-version installed-version))))))

(defun literate-config-version--handle-mismatch (package-name config-version installed-version file)
  "Handle version mismatch for PACKAGE-NAME."
  (let ((msg (format "VERSION MISMATCH: %s\n  Config: %s\n  Installed: %s\n\nFile: %s"
                     package-name config-version installed-version file)))
    (if literate-config-enforce-versions
        (progn
          ;; Store error for dashboard display
          (push (list :package package-name
                      :config-version config-version
                      :installed-version installed-version
                      :file file)
                literate-config-version--mismatches)
          (error msg))
      ;; Just warn if enforcement disabled
      (message "Warning: %s" msg))))

(defvar literate-config-version--mismatches nil
  "List of version mismatches found during loading.")

;; ════════════════════════════════════════════════════════════════════
;; § VERSION UPDATE HELPER
;; ════════════════════════════════════════════════════════════════════

;;;###autoload
(defun literate-config-update-package-version (package-name)
  "Update version for PACKAGE-NAME in its org config file."
  (interactive
   (list (completing-read "Update version for package: "
                          (mapcar #'car literate-config-scanner--packages)
                          nil t)))
  
  (let* ((pkg-info (assoc package-name literate-config-scanner--packages))
         (file (plist-get (cdr pkg-info) :file))
         (old-version (plist-get (cdr pkg-info) :version))
         (installed-version (literate-config-version--get-installed package-name)))
    
    (unless file
      (user-error "Package %s not found" package-name))
    
    (unless installed-version
      (user-error "Cannot detect installed version for %s" package-name))
    
    ;; Confirm update
    (when (y-or-n-p 
           (format "Update %s version from %s to %s? " 
                   package-name old-version installed-version))
      
      ;; Update :VERSION: property in org file
      (with-current-buffer (find-file-noselect file)
        (save-excursion
          (goto-char (point-min))
          (when (re-search-forward "^:VERSION:\\s-+\\(.*\\)$" nil t)
            (replace-match installed-version nil nil nil 1)
            (save-buffer)
            (message "✓ Updated %s to %s" package-name installed-version)))
        
        ;; Offer to show changelog
        (when (y-or-n-p "View changelog? ")
          (literate-config-version--show-changelog 
           package-name old-version installed-version))))))

(defun literate-config-version--show-changelog (package-name old-version new-version)
  "Show changelog between OLD-VERSION and NEW-VERSION for PACKAGE-NAME."
  (let* ((repo-dir (straight--repos-dir package-name))
         (default-directory repo-dir))
    (if (and repo-dir (file-exists-p repo-dir))
        (let ((log (shell-command-to-string
                    (format "git log --oneline %s..%s 2>/dev/null" old-version new-version))))
          (with-current-buffer (get-buffer-create "*Package Changelog*")
            (erase-buffer)
            (insert (format "Changes in %s: %s → %s\n\n" 
                            package-name old-version new-version))
            (if (string-empty-p log)
                (insert "No commits found between these versions.\n")
              (insert log))
            (goto-char (point-min))
            (special-mode)
            (display-buffer (current-buffer))))
      (message "Cannot show changelog - repo directory not found"))))

;; ════════════════════════════════════════════════════════════════════
;; § NEW PACKAGE VERSION DETECTION
;; ════════════════════════════════════════════════════════════════════

(defun literate-config-version--detect-for-new-package (package-name straight-spec)
  "Detect version for new package creation.
Returns version string or nil."
  (let ((repo-url (literate-config-version--parse-repo-url straight-spec)))
    (or
     ;; Try 1: Fetch from git remote (any host)
     (when repo-url
       (message "Fetching latest version from %s..." repo-url)
       (literate-config-version--fetch-latest-from-git repo-url))
     
     ;; Try 2: If already installed, check local git repo
     (literate-config-version--get-installed package-name)
     
     ;; Try 3: Return nil to prompt user
     nil)))

(provide 'literate-config-version)
;;; literate-config-version.el ends here
