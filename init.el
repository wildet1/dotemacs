(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq inhibit-startup-screen t)

;; Melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; THEME
;; (use-package gruvbox-theme
;;  :ensure t
;;  :config
;;  (load-theme 'gruvbox-dark-medium t))
(load-theme 'modus-vivendi)
(define-key global-map (kbd "<f5>") #'modus-themes-toggle)

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
  ("C-x b"   . consult-buffer)
  ("C-s"     . consult-line)
  ("M-g g"   . consult-goto-line)
  ("M-g i"   . consult-imenu)
  ("C-x p b" . consult-project-buffer))

(use-package sly
  :ensure t
  :config
  (setq inferior-lisp-program "/usr/bin/sbcl")
  :hook
  (lisp-mode . sly-editing-mode))

(use-package eshell-syntax-highlighting
  :ensure t
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode 1))

(use-package vterm
  :ensure t)

(use-package multi-vterm
  :ensure t)

(use-package emms
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

(use-package popper
  :ensure t
  :bind (("C-;" . popper-toggle)
         ("C-'" . popper-cycle)
         ("C-M-;" . popper-toggle-type))
  :config
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
  (popper-echo-mode 1)
  (popper-mode 1))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-\""        . mc/skip-to-next-like-this)
         ("C-:"         . mc/skip-to-previous-like-this)))

(use-package org-bullets
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
  :custom
  (avy-timeout-seconds 0.25)
  (avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind
  ("M-j" . avy-goto-char-timer)
  ("M-J" . avy-goto-line))    

(use-package ace-window
  :ensure t
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-scope 'frame)              
  :bind
  ("M-o" . ace-window))

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



;; Scripts
(defun my/init-updater ()
  (interactive)
  (let* ((hosts '("t440p" "t420" "desk" "core"))
         (host (completing-read "Sync init.el to: " (remove (system-name) hosts)))
         (remote-dir (format "/ssh:%s:~/.emacs.d/" host)))
    (copy-file "~/.emacs.d/init.el"
               (concat remote-dir "init.el")
               t)))

(defun my/ssh-cd ()
  (interactive)
  (let* ((hosts '("t440p" "t420" "desk" "core"))
         (host (completing-read "Cd Into: " (remove (system-name) hosts)))
         (win (split-window-below (- (round (* (frame-height) 0.25))))))
    (select-window win)
    (eshell)
    (eshell/clear-scrollback)
    (insert (format "cd /ssh:%s:" host))
    (eshell-send-input)))

(require 'battery)
(when (member (system-name) '("t440p" "t420"))
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


