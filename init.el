; Manually load package instead of waiting until after init.el is loaded
(package-initialize)
; Disable loading package again after init.el
(setq package-enable-at-startup nil)

; Enable "package", for installing packages
; Add some common package repositories
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))

; Use "package" to install "use-package", a better package management and config system
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; org-journal
(use-package org-journal :ensure t)

;; org setup
(setq org-todo-keywords
      '((sequence "TODO" "NEXT" "DONE")))

;; flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; disable secondary selection w/ mouse
(global-set-key [remap mouse-drag-secondary] 'mouse-drag-region)
(global-set-key [remap mouse-set-secondary] 'mouse-set-region)
(global-set-key [remap mouse-start-secondary] 'mouse-set-point)
(global-set-key [remap mouse-yank-secondary] 'mouse-yank-primary)
(global-set-key [remap mouse-secondary-save-then-kill] 'mouse-save-then-kill)

;; LANGS
(use-package company :ensure t)
(use-package company-box :ensure t
  :hook (company-mode . company-box-mode))

;;(use-package auctex :ensure t)
;; Python
;; (use-package elpy
;;   :ensure t
;;   :pin elpy
;;   :config
;;   (elpy-enable)
;;   ;; Enable elpy in a Python mode
;;   (add-hook 'python-mode-hook 'elpy-mode)
;;   (add-hook 'python-mode-hook 'blacken-mode)
;;   (setq elpy-rpc-backend "jedi")
;;   ;; Open the Python shell in a buffer after sending code to it
;;   (add-hook 'inferior-python-mode-hook 'python-shell-switch-to-shell)
;;   ;; Use IPython as the default shell, with a workaround to accommodate IPython 5
;;   ;; https://emacs.stackexchange.com/questions/24453/weird-shell-output-when-using-ipython-5
;;   (setq python-shell-interpreter "jupyter-console")
;;   (setq python-shell-interpreter-args "--simple-prompt")
;;   (setq python-shell-prompt-detect-failure-warning nil)
;;   (setq python-shell-completion-native-enable nil)
;;   ;; Enable pyvenv, which manages Python virtual environments
;;   (pyvenv-mode 1)
;;   ;; Tell Python debugger (pdb) to use the current virtual environment
;;   ;; https://emacs.stackexchange.com/questions/17808/enable-python-pdb-on-emacs-with-virtualenv
;;   (setq gud-pdb-command-name "python -m pdb "))

(use-package pipenv :ensure t)
(use-package poetry :ensure t)
;; notebooks
(use-package ein :ensure t)
(use-package jupyter :ensure t)
(setq comp-deferred-compilation-deny-list (list "jupyter"))
;; python formatting
(use-package blacken :ensure t :init (setq blacken-line-length 100) (add-hook 'python-mode-hook 'blacken-mode))
;; isort
;; (use-package py-isort
;;   :ensure t
;;   :init
;;   ;;(setq py-isort-options '("--lines=100" "--multi-line=3" "--trailing-comma"))
;;   (add-hook 'before-save-hook 'py-isort-before-save))
;; python test running
(use-package pytest :ensure t)
;; python virtualenvs
(use-package conda :ensure t)
(use-package pipenv :ensure t)
(electric-pair-mode 1)
;; language server mode
(use-package lsp-mode
  :ensure t
  :defer t
  :init (setq lsp-keymap-prefix "C-c l")
  :hook ((python-mode . lsp-deferred)))
(with-eval-after-load 'lsp
  (setq lsp-pylsp-plugins-pydocstyle-enabled nil))
(use-package lsp-ivy :ensure t :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :ensure t :commands lsp-treemacs-errors-list)
(use-package lsp-latex :ensure t)
;; Provides visual help in the buffer
;; For example definitions on hover.
;; The `imenu` lets me browse definitions quickly.
(use-package lsp-ui
  :ensure t
  :defer t
  :config
  (setq lsp-ui-sideline-enable nil
	    lsp-ui-doc-delay 2)
  :hook (lsp-mode . lsp-ui-mode)
  :bind (:map lsp-ui-mode-map
	      ("C-c i" . lsp-ui-imenu)))

;; Integration with the debug server
(use-package dap-mode
  :ensure t
  :defer t
  :after lsp-mode
  :config
  (dap-auto-configure-mode))

;; PDM
(defun pdm-get-python-executable (&optional dir)
    (let ((pdm-get-python-cmd "pdm info --python"))
      (string-trim
       (shell-command-to-string
        (if dir
            (concat "cd "
                    dir
                    " && "
                    pdm-get-python-cmd)
          pdm-get-python-cmd)))))


(defun pdm-get-packages-path (&optional dir)
  (let ((pdm-get-packages-cmd "pdm info --packages"))
    (concat (string-trim
             (shell-command-to-string
              (if dir
                  (concat "cd "
                          dir
                          " && "
                          pdm-get-packages-cmd)
                pdm-get-packages-cmd)))
            "/lib")))

;; (use-package lsp-pyright
;;   :ensure t
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-pyright)
;;                           (lsp))))  ; or lsp-deferred
;; ;; (use-package lsp-python-ms
;; ;;   :ensure t
;; ;;   :init (setq lsp-python-ms-auto-install-server t)
;; ;;   :hook (python-mode . (lambda ()
;; ;;                           (require 'lsp-python-ms)
;; ;;                           (lsp))))  ; or lsp-deferred

;; (setq lsp-log-io t)
;; (setq lsp-pyright-use-library-code-for-types t)
;;    (setq lsp-pyright-diagnostic-mode "workspace")
;;    (lsp-register-client
;;      (make-lsp-client
;;        :new-connection (lsp-tramp-connection (lambda ()
;;                                        (cons "pyright-langserver"
;;                                              lsp-pyright-langserver-command-args)))
;;        :major-modes '(python-mode)
;;        :remote? t
;;        :server-id 'pyright-remote
;;        :multi-root t
;;        :priority 3
;;        :initialization-options (lambda () (ht-merge (lsp-configuration-section "pyright")
;;                                                     (lsp-configuration-section "python")))
;;        :initialized-fn (lambda (workspace)
;;                          (with-lsp-workspace workspace
;;                            (lsp--set-configuration
;;                            (ht-merge (lsp-configuration-section "pyright")
;;                                      (lsp-configuration-section "python")))))
;;        :download-server-fn (lambda (_client callback error-callback _update?)
;;                              (lsp-package-ensure 'pyright callback error-callback))
;;        :notification-handlers (lsp-ht ("pyright/beginProgress" 'lsp-pyright--begin-progress-callback)
;;                                      ("pyright/reportProgress" 'lsp-pyright--report-progress-callback)
;;                                      ("pyright/endProgress" 'lsp-pyright--end-progress-callback))))

(use-package numpydoc
  :ensure t
  :bind (:map python-mode-map
              ("C-c C-n" . numpydoc-generate)))

;; R
(use-package ess :ensure t)
(use-package poly-R :ensure t)
(use-package format-all :ensure t
  :hook (ess-r-mode . format-all-mode))

(use-package julia-mode
  :ensure t
  :mode ("\\.jl\\'" . ess-julia-mode)
  :init
  (add-hook 'julia-mode-hook 'ess-julia-mode)
  )

(use-package vterm :ensure t)

(use-package julia-snail
  :ensure t
  :requires vterm
  :hook (julia-mode . julia-snail-mode))

(use-package lsp-julia
  :ensure t
  :config
  (setq lsp-julia-default-environment "~/.julia/environments/v1.6")
  :init (add-hook 'ess-julia-mode-hook 'lsp-mode))

(lsp-register-client
    (make-lsp-client :new-connection
        (lsp-stdio-connection '("R" "--slave" "-e" "languageserver::run()"))
        :major-modes '(ess-r-mode inferior-ess-r-mode)
        :server-id 'lsp-R))

;; js prettier
(use-package prettier-js
  :ensure t
  :init (add-hook 'js-mode-hook 'prettier-js-mode))

;; graphviz
(use-package graphviz-dot-mode :ensure t)

;; rest-client
(use-package restclient :ensure t)

;; projectile
(use-package projectile :ensure t)

;; YAML
(use-package yaml-mode :ensure t)

;; MISC

;; kill ring
(use-package browse-kill-ring :ensure t)
(browse-kill-ring-default-keybindings)
;; windows
;; Navigate window layouts with "C-c <left>" and "C-c <right>"

(add-hook 'after-init-hook 'winner-mode)
;; Make "C-x o" prompt for a target window when there are more than 2
(use-package switch-window :ensure t)
(setq-default switch-window-shortcut-style 'alphabet)
(setq-default switch-window-timeout nil)
(global-set-key (kbd "C-x o") 'switch-window)
;; neotree
(use-package treemacs :ensure t)
(use-package neotree :ensure t)
(use-package all-the-icons :ensure t)
(global-set-key [f8] 'neotree-toggle)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; ivy autocompletion
(use-package ivy :ensure t)
(ivy-mode)
(define-key ivy-minibuffer-map (kbd "C-j") 'ivy-immediate-done)
(define-key ivy-minibuffer-map (kbd "C-m") 'ivy-alt-done)
;; magit
(use-package magit :ensure t)

;; which-key for keybinding completion
(use-package which-key :ensure t)
(which-key-mode)

;; C-n add new lines at the end of buffer
(setq next-line-add-newlines t)
;; open emacs full screen
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Make Emacs highlight paired parentheses
(show-paren-mode 1)
;; make emacs show column numbers
(setq column-number-mode t)
;; Make emacs auto revert buffers
(global-auto-revert-mode t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
;;(global-linum-mode t)
(add-hook 'prog-mode-hook 'linum-mode)
(tool-bar-mode -1)
;;reflow text to column 80
(setq-default fill-column 80)

(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$" "" (shell-command-to-string
					  "$SHELL --login -c 'echo $PATH'"
						    ))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;; Don't create backup files~
(setq make-backup-files nil)
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; THEMES
;; nord theme
(setq custom-safe-themes t)
(use-package zenburn-theme :ensure t)
(use-package dream-theme :ensure t)
(use-package nord-theme :ensure t)
(load-theme 'nord t)

;; venv workon
(setenv "WORKON_HOME" "/home/alex/.virtualenvs")
;;(setenv "WORKON_HOME" "/home/alex/.local/share/virtualenvs")
;;(setenv "WORKON_HOME" "/home/jekyllo/envs")
;; no tabs
(setq-default indent-tabs-mode nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(conda-anaconda-home "/home/alex/miniconda3/")
 '(conda-env-home-directory "/home/alex/miniconda3/")
 '(custom-safe-themes
   '("e6df46d5085fde0ad56a46ef69ebb388193080cc9819e2d6024c9c6e27388ba9" "37768a79b479684b0756dec7c0fc7652082910c37d8863c35b702db3f16000f8" default))
 '(jupyter-repl-echo-eval-p t)
 '(lsp-eslint-auto-fix-on-save t)
 '(lsp-latex-build-args
   '("-pdf" "-interaction=nonstopmode" "-bibtex" "-synctex=1" "%f"))
 '(lsp-latex-build-on-save t)
 '(lsp-latex-chktex-on-edit t)
 '(lsp-latex-chktex-on-open-and-save nil)
 '(lsp-pylsp-plugins-flake8-enabled nil)
 '(lsp-pylsp-plugins-flake8-max-line-length 100)
 '(lsp-pylsp-plugins-pycodestyle-enabled nil)
 '(lsp-pylsp-plugins-pydocstyle-enabled nil)
 '(lsp-pylsp-plugins-pylint-enabled t)
 '(package-selected-packages
   '(poly-R org-journal julia-formatter lsp-julia julia-mode format-all ess poetry numpydoc pyment py-pyment yaml-mode yaml restclient company-box prettier-js flycheck py-isort projectile graphviz-dot-mode jupyter emacs-jupyter browse-kill-ring pytest company-bibtex switch-window blacken ein lsp-latex lsp-lens lsp-ivy lsp-treemacs which-key treemacs lsp-pyright lsp-mode pipenv conda use-package nord-theme neotree magit ivy elpy all-the-icons))
 '(prettier-js-args nil)
 '(py-isort-options nil)
 '(python-shell-interpreter-interactive-arg "")
 '(whitespace-style '(lines-tail)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
