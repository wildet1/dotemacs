(use-package popper
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
