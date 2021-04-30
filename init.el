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

;; LANGS
;; TeX
(use-package auctex :ensure t)
;; Python
(use-package elpy
  :ensure t
  :pin elpy
  :config
  (elpy-enable)
  ;; Enable elpy in a Python mode
  (add-hook 'python-mode-hook 'elpy-mode)
  (setq elpy-rpc-backend "jedi")
  ;; Open the Python shell in a buffer after sending code to it
  (add-hook 'inferior-python-mode-hook 'python-shell-switch-to-shell)
  ;; Use IPython as the default shell, with a workaround to accommodate IPython 5
  ;; https://emacs.stackexchange.com/questions/24453/weird-shell-output-when-using-ipython-5
  (setq python-shell-interpreter "jupyter-console")
  (setq python-shell-interpreter-args "--simple-prompt")
  ;; Enable pyvenv, which manages Python virtual environments
  (pyvenv-mode 1)
  ;; Tell Python debugger (pdb) to use the current virtual environment
  ;; https://emacs.stackexchange.com/questions/17808/enable-python-pdb-on-emacs-with-virtualenv
  (setq gud-pdb-command-name "python -m pdb "))

;; python virtualenvs 
(use-package conda :ensure t)
(use-package pipenv :ensure t)

;; language server mode
(use-package lsp-mode :ensure t)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(setq lsp-log-io t)
(setq lsp-pyright-use-library-code-for-types t)
   (setq lsp-pyright-diagnostic-mode "workspace")
   (lsp-register-client
     (make-lsp-client
       :new-connection (lsp-tramp-connection (lambda ()
                                       (cons "pyright-langserver"
                                             lsp-pyright-langserver-command-args)))
       :major-modes '(python-mode)
       :remote? t
       :server-id 'pyright-remote
       :multi-root t
       :priority 3
       :initialization-options (lambda () (ht-merge (lsp-configuration-section "pyright")
                                                    (lsp-configuration-section "python")))
       :initialized-fn (lambda (workspace)
                         (with-lsp-workspace workspace
                           (lsp--set-configuration
                           (ht-merge (lsp-configuration-section "pyright")
                                     (lsp-configuration-section "python")))))
       :download-server-fn (lambda (_client callback error-callback _update?)
                             (lsp-package-ensure 'pyright callback error-callback))
       :notification-handlers (lsp-ht ("pyright/beginProgress" 'lsp-pyright--begin-progress-callback)
                                     ("pyright/reportProgress" 'lsp-pyright--report-progress-callback)
                                     ("pyright/endProgress" 'lsp-pyright--end-progress-callback))))


;; THEMES
;; nord theme
(use-package nord-theme :ensure t)
(load-theme 'nord)

;; MISC
;; neotree
(use-package treemacs :ensure t)
(use-package neotree :ensure t)
(use-package all-the-icons :ensure t)
(global-set-key [f8] 'neotree-toggle)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; ivy autocompletion
(use-package ivy :ensure t)
(ivy-mode)

;; magit
(use-package magit :ensure t)

;; which-key for keybinding completion
(use-package which-key :ensure t)
(which-key-mode)

(global-linum-mode t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("37768a79b479684b0756dec7c0fc7652082910c37d8863c35b702db3f16000f8" default)))
 '(package-selected-packages
   (quote
    (auctex which-key lsp-treemacs treemacs lsp-mode pipenv conda magit ivy all-the-icons neotree use-package nord-theme elpy))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
