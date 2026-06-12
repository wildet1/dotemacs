;; This are functions that read /etc/os-release. They then create an
;; update command for that distro, and execute it async. For now,
;; symlink this file to lisp.

(defmacro my/pkg-update (name &rest body)
  "Define a package update action for NAME."
  `(cons ,(symbol-name name)
         (lambda () ,@body)))

(defun my/strip-os-release-quotes (s)
  "Remove surrounding quotes from OS release values."
  (if (and (string-prefix-p "\"" s)
           (string-suffix-p "\"" s))
      (substring s 1 -1)
    s))

(defun my/os-release-parse ()
  "Return clean alist from /etc/os-release."
  (when (file-readable-p "/etc/os-release")
    (with-temp-buffer
      (insert-file-contents "/etc/os-release")
      (let (result)
        (goto-char (point-min))
        (while (re-search-forward
                "^\\([A-Z_]+\\)=\\(.*\\)$"
                nil t)
          (let* ((key (downcase (match-string 1)))
                 (val (match-string 2)))

            ;; IMPORTANT FIX HERE
            (setq val (my/strip-os-release-quotes val))
            (setq val (string-trim val))

            (push (cons key val) result)))
        result))))

(defun my/distro-ids ()
  "Return list of distro identifiers from ID and ID_LIKE."
  (let* ((os (my/os-release-parse))
         (id (cdr (assoc "id" os)))
         (like (cdr (assoc "id_like" os))))
    (delete-dups
     (append
      (when id (list id))
      (when like (split-string like "[ \t]+" t))))))

(defvar my/pkg-update-commands nil)

(defun my/resolve-update-command ()
  "Return update command string for current distro."
  (let* ((ids (my/distro-ids))
         (table my/pkg-update-commands)
         found)
    (dolist (id ids)
      (unless found
        (setq found (cdr (assoc id table)))))

    (unless found
      (error "Unknown distro: %S" ids))

    (funcall found)))

(defun my/update-system ()
  "Update system packages asynchronously depending on distro."
  (interactive)
  (async-shell-command
   (my/resolve-update-command)
   "*system-update*"))

(provide 'system-update)
