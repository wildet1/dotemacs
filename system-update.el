;; This are functions that read /etc/os-release. They then create an
;; update command for that distro, and execute it async. For now,
;; symlink this file to lisp.

(defmacro my/pkg-update (name &rest body)
  "Define a package update action for NAME."
  `(cons ,(symbol-name name)
         (lambda () ,@body)))

(defun my/os-release-parse ()
  "Return alist of fields from /etc/os-release."
  (with-temp-buffer
    (insert-file-contents "/etc/os-release")
    (let (result)
      (while (re-search-forward "^\\([^=]+\\)=\\(.*\\)$" nil t)
        (let ((key (match-string 1))
              (val (match-string 2)))
          (setq val (string-trim val "\"'"))
          (push (cons key val) result)))
      result)))

(defun my/distro-ids ()
  "Return list of distro identifiers from ID and ID_LIKE."
  (let* ((os (my/os-release-parse))
         (id (cdr (assoc "ID" os)))
         (like (cdr (assoc "ID_LIKE" os))))
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
