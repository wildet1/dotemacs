(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq inhibit-startup-screen t)

;; Melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; THEME
(use-package gruvbox-theme
 :ensure t)

(use-package ef-themes
  :ensure t
  :init
  (modus-themes-include-derivatives-mode 1)
  :bind
  ;; When accessing the function row on many laptops,
  ;; a rebound control key will not work. In my case,
  ;; I have to hold my actual control key, to access
  ;; in this case the theme selector.
  (("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random))
  :config
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t))

;; `modus-themes-load-random', `modus-themes-load-random-dark',
;; `modus-themes-load-random-light').
;; (load-theme 'gruvbox-dark-medium t)
(modus-themes-load-theme 'ef-bio)

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-startup-banner 'official)
  ;; (setq dashboard-startup-banner "~/Pictures/emacs-banner.png")
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items
        '((recents  . 8)))

  (setq dashboard-footer-messages
       '("A Monad is a Monoid in the Category of Endofunctors"))

  (setq dashboard-banner-logo-title
        "Welcome!"))
(dashboard-setup-startup-hook)
(defun my/show-dashboard-on-client (&rest _)
  (when (display-graphic-p)
    (dashboard-open)))

(add-hook 'server-after-make-frame-hook #'my/show-dashboard-on-client)

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil  
  :bind (:map vertico-map
              ("RET"  . vertico-directory-enter)
              ("DEL"  . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package consult
  :ensure t
  :bind
  (("C-x b"   . consult-buffer)
   ("C-s"     . consult-line)
   ("M-g g"   . consult-goto-line)
   ("M-g i"   . consult-imenu)
   ("C-x p b" . consult-project-buffer)
   ("C-x f"   . consult-find))

  :custom
  (consult-find-command
   "fd --color=never --full-path --hidden --type f"))

(use-package embark
  :ensure t

  :bind
  (("M-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; Show the Embark target at point via Eldoc.
  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
(defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
        (which-key--show-keymap
         (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
         (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
         nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator before completing the action."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator)

  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t) 

(use-package sly
  :ensure t
  :hook
  (lisp-mode . sly-editing-mode)
  :config
  (setq sly-complete-symbol-function #'sly-flex-completions)
  (setq inferior-lisp-program "/usr/local/bin/sbcl")
  (setq sly-complete-in-steps t)
  (setq sly-description-autofocus t))

(use-package eshell-syntax-highlighting
  :ensure t
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode 1))

(use-package vterm
  :ensure t)

(use-package multi-vterm
  :defer t
  :ensure t)

(use-package all-the-icons :ensure t)
;; Run M-x all-the-icons-install-fonts

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package olivetti
  :defer t
  :ensure t)

(use-package org-present
  :defer t
  :ensure t
  :hook
  ((org-present-mode . (lambda ()
                         (org-present-big)
                         (org-display-inline-images)
                         (org-present-hide-cursor)
                         (org-present-read-only)
                         (olivetti-mode 1)
                         (olivetti-set-width 80)))

   (org-present-mode-quit-hook . (lambda ()
     (org-present-small)
     (org-remove-inline-images)
     (org-present-show-cursor)
     (org-present-read-write)
     (olivetti-mode 0)
     (run-at-time 0.05 nil
                  (lambda ()
                    (setq cursor-type 'box)))))))

(use-package emms
  :defer t
  :ensure t
  :config
  (emms-all)
  (setq emms-player-list '(emms-player-mpv))
  (setq emms-track-description-function
	(lambda (track)
          (emms-track-get track 'info-title)))
  :bind
  ("C-c m P" . 'emms-pause)
  ("C-c m n" . 'emms-next)
  ("C-c m p" . 'emms-previous)
  ("C-c m d" . 'emms-play-directory)
  ("<f9>" . (lambda ()
              (interactive)
              (let ((win (get-buffer-window " *EMMS Playlist*")))
                (if win
                    (delete-window win)
                  (select-window (display-buffer " *EMMS Playlist*")))))))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-c m a"     . mc/mark-all-dwim)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package org-bullets
  :defer t
  :ensure t)

(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode       . enable-paredit-mode)
         (lisp-mode             . enable-paredit-mode)
         (lisp-interaction-mode . enable-paredit-mode)
         (scheme-mode           . enable-paredit-mode)
         (clojure-mode          . enable-paredit-mode)
	 (ielm-mode             . enable-paredit-mode)))  

(use-package avy
  :ensure t
  :bind
  (("M-j"   . avy-goto-char-in-line)
   ("M-g c" . avy-goto-char-timer)
   ("M-g l" . avy-goto-line)
   ("M-g w" . avy-goto-word-1)))

(use-package ace-window
  :ensure t
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-scope 'frame)              
  :bind
  ("M-o" . ace-window))

;; This is a package to center
;; the vertico buffer, such as
;; the one that appears when
;; pressing M-x to execute an
;; extended command.
;;
;; I have had problems with it
;; inheriting my buffers text
;; scaling, which made it
;; unreadable if I had large
;; buffer text. This is hard
;; to fix and is due to the
;; nature of the posframe
;; framework.

;; There are alternatives
;; that serve the same
;; function, such 

(use-package vertico-posframe
  :disabled t
  :ensure t
  :init
  (vertico-posframe-mode 1)
  :config)

(use-package popper
  :disabled t
  :ensure t
  :init
  (setq popper-reference-buffers
        '(Custom-mode
          compilation-mode
          messages-mode
          help-mode
          occur-mode
          "^\\*Warnings\\*"
          "^\\*Compile-Log\\*"
          "^\\*Backtrace\\*"
          "^\\*Apropos\\*"
          "^Calc:"
          "^\\*Shell Command Output\\*"
          "^\\*Async Shell Command\\*"
          "^\\*Completions\\*"))
  :bind (("C-;" . popper-toggle)
         ("C-'" . popper-cycle)
         ("C-M-;" . popper-toggle-type))
  :config
  (popper-mode 1)
  (popper-echo-mode 1))

;; Obvious
(menu-bar-mode 0)
(tool-bar-mode 0)  
(scroll-bar-mode 0)
;; (global-display-line-numbers-mode 1)
(electric-pair-mode t)
(add-to-list 'default-frame-alist '(font . "Iosevka Nerd Font-11"))
(setq scroll-conservatively 101)
(setq display-time-24hr-format 1)
(display-time-mode 1)
(setq select-enable-primary t)
(setq disabled-command-function nil)
(setq select-enable-clipboard t)
;; (setq scroll-margin 5)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(which-key-mode 1)
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies  'always)
(setq dired-listing-switches "-alh --group-directories-first")
(recentf-mode 1)
(global-hl-line-mode 1)
(setq global-hl-line-sticky-flag t)

;; Eshell
(defvar my/eshell-hostname (system-name)
  "Cached hostname for eshell prompt.")

(setq eshell-prompt-function
      (lambda ()
        (concat
         (propertize (system-name) 'face '(:foreground "#a8a8a8"))
         (propertize " ❯ " 'face '(:foreground "#595959"))
         (propertize (abbreviate-file-name (eshell/pwd)) 'face '(:foreground "#c4d0e7"))
         (propertize " λ " 'face '(:foreground "#595959")))))
(setq eshell-prompt-regexp " λ $")
(setq eshell-banner-message "") 
(setq eshell-aliases-file "~/.emacs.d/aliases")


;; Tab-bar
(global-set-key (kbd "C-,") 'tab-bar-switch-to-prev-tab)
(global-set-key (kbd "C-.") 'tab-bar-switch-to-next-tab)
(setq tab-bar-show 1) ; Hides the bar when only one tab
;; (setq tab-bar-tab-hints t) ; Index number on tabs
(setq tab-bar-close-button-show nil)
(setq tab-bar-new-button-show nil)

;; Keybindings
;; Kill Buffer C-x k
;; Cycle window focus C-x o
;; Zoom C-x C-+
;; Mark word M-@
;; Mark Sexp C-M-@
;; (Un)Comment selection M-;
;; (Un)Comment line C-x C-;
;; M-q fix long line
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "<f8>") #'my/eshell-toggle)
(global-set-key (kbd "<f7>") 'vterm)
(global-set-key (kbd "C-c s") #'my/ssh-cd)
(global-set-key (kbd "C-c u") #'my/init-updater)
(global-set-key (kbd "C-c x") #'compile)
(global-set-key (kbd "C-c C-l") 'global-display-line-numbers-mode)
(global-set-key (kbd "C-c C-r") 'consult-recent-file)
(global-set-key (kbd "M-n") #'scroll-up-line)
(global-set-key (kbd "M-p") #'scroll-down-line)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c d")
	      (lambda ()
		(interactive)
		(dired-do-shell-command "du -sh" nil (dired-get-marked-files)))))

(add-hook 'eshell-mode-hook
          (lambda ()
            (local-set-key (kbd "C-l")
                           (lambda ()
                             (interactive)
                             (eshell/clear-scrollback)
			     (eshell-send-input)))))

;; Kill all buffers that are not safe 
(global-set-key (kbd "C-c o")
  (lambda () (interactive)
    (let ((safe (list (current-buffer)
                      (get-buffer "*Messages*")
                      (get-buffer "*scratch*")
		      (get-buffer "*eshell*"))))
      (mapc #'kill-buffer
            (cl-set-difference (buffer-list) safe)))))

;; Org
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-directory "~/org/")
(setq org-default-notes-file (concat org-directory "notes.org"))

(setq org-agenda-files 
      (list (concat org-directory "tasks.org")
	    (concat org-directory "notes.org")))

(setq org-capture-templates
  '(("i" "Idea" entry
     (file org-default-notes-file)
     "* %U %?")
    ("t" "Todo" entry
     (file org-default-notes-file)
     "* TODO %?")
    ("s" "Source" entry
     (file org-default-notes-file)
     "* %U %?\n:PROPERTIES:\n:SOURCE: %^{Source}\n:END:")))

(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'system-update)
(setq my/pkg-update-commands
      (list
       (my/pkg-update void
         "sudo xbps-install -Syu")

       (my/pkg-update arch
         (if (executable-find "yay")
             "yay -Syu"
           "sudo pacman -Syu"))

       (my/pkg-update debian
         "sudo apt update && sudo apt upgrade -y")

       (my/pkg-update ubuntu
         "sudo apt update && sudo apt upgrade -y")

       (my/pkg-update fedora
         "sudo dnf upgrade --refresh")))

;; Functions
(require 'battery)
(when (member (system-name) '("t440p" "t420" "x1c"))
  (setq battery-mode-line-format " [%b%p%% %t]"
        battery-update-interval 30)
  (display-battery-mode 1))

(defun my/eshell-toggle ()
  (interactive)
  (let* ((buf-name "*eshell popup*")
         (win (get-buffer-window buf-name)))
    (if win
        (delete-window win)
      (select-window (display-buffer
                      (or (get-buffer buf-name)
                          (save-window-excursion
                            (eshell t)
                            (rename-buffer buf-name)
                            (current-buffer))))))))

;; Display-buffer alist
(add-to-list 'display-buffer-alist
             '("^ \\*EMMS Playlist\\*"
               (display-buffer-in-side-window)
               (side . left)
               (window-width . 0.2)))

(add-to-list 'display-buffer-alist
             '("\\*Org Select\\*\\|CAPTURE"
               (display-buffer-at-bottom)
               (window-height . 0.25)))

(add-to-list 'display-buffer-alist
             '("\\*eshell popup\\*"
               (display-buffer-in-side-window)
               (side . top)
               (window-height . 0.3)))

