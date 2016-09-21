;; !!! do package-install to pre-load the cache on new installs !!!
;;magit diff current file against some branch/commit
;;erlang mode doesn't reindent on enter
;;ediff changes don't make the commit
;;elisp indentation gigantic in lambdas
;;erlang shell working like normal shell and compiling on entry (awesome).
;;freaking temporary files (might be working now)
;;save buffer on leader-q if the buffer has a file attached to it
;;make quit from magit buffers with <leader>q always do the right thing
;;make <leader>q conditionally run server-edit if in needed (donno how to check that...)
;;  (or use <space><space> to server-edit instead of save [that would be pretty slick])
;;ga/gb in ediff
;;definition of "word" characters in various languages
;;definition of paragraph [[ ]] movement in various languages
;;change out of eshell when it's the only window
;;acting tweaky on * search (No idea what to do about this)
;; * only going forward for highlight
;;config in hook without restart of emacs (maybe just run the hooken?)
;;gitgutter updating
;;better customization on-the-fly: maybe make f1 reload the current mode since stuff gets trucked up
;;hotkeys for commenting
;;horkage line numbers on windows to the right
;;load fresh emacs w/o having to do a list-packages first
;;highlight in every file when searching (especially with *);
;;longer timeout of search highlighting
;;scss-mode (or just make css mode work for scss files)
;;css-mode indent (at 2, no tabs)
;;css-mode strange indentation broken issues
;;eshell clear input
;;eshell clear whole buffer
;;K for reformat line
;;single escape in helm
;;single window for dired, please
;;moving directories in dired is horked (probably because of helm)
;;linum horkage with missing line numbers
;;tripple escape

;;; learn:
;;org mode
;;tern
;;helm stuff (search in file?)
;;get emacs source code to start learning the internals

;;; remember:
;;re-builder

;; server
(load "server")
(unless (server-running-p) (server-start))

; Set up Emacs' `exec-path' and PATH environment variable to match
; that used by the user's shell.
; This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
(let ((path-from-shell
       (shell-command-to-string "$SHELL --login -c 'echo -n $PATH'")))
  (setenv "PATH" path-from-shell)
  (setq exec-path (split-string path-from-shell ":")))

;; packages
(setq packages
  '(ace-jump-mode
    helm helm-projectile projectile magit minimap
    goto-last-change jabber yasnippet git-gutter-fringe
    elscreen twittering-mode
    ack-and-a-half fill-column-indicator
  ;evil
    evil
    evil-leader
  ;themes
    noctilux-theme
    solarized-theme
    zenburn-theme helm
    github-theme
    anti-zenburn-theme
  ;;languages
    erlang
    zencoding-mode emmet-mode ;html
    js2-mode
  ))

;; repos
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(setq package-load-list '(all))
(package-initialize)

;; install packages
(dolist (p packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; general
(fset 'yes-or-no-p 'y-or-n-p)

;; evil
(require 'evil)
(global-evil-leader-mode)
(evil-mode 1)
(setq leader-map (make-sparse-keymap))
(defun map-leader (key val) (define-key leader-map key val))
(defun map-normal (key val) (define-key evil-normal-state-map key val))
(defun map-insert (key val) (define-key evil-insert-state-map key val))
(defun map-normal-local (key val) (define-key evil-normal-state-local-map key val))
(defun map-insert-local (key val) (define-key evil-insert-state-local-map key val))
(map-normal " " leader-map) ;setup leader map
(evil-set-initial-state 'help-mode 'normal)
(evil-set-initial-state 'man-mode 'normal)
(evil-set-initial-state 'eshell-mode 'emacs)
(setq-default evil-shift-width 2)
(setq evil-shift-width 2)
;(map-normal key minibuffer-local-map [escape] 'keyboard-quit)
;(map-normal [escape] 'keyboard-quit)
;(map-normal [escape] 'keyboard-quit)
;(map-normal key minibuffer-local-map [escape] 'keyboard-quit)
;(map-normal key minibuffer-local-ns-map [escape] 'keyboard-quit)
;(map-normal key minibuffer-local-completion-map [escape] 'keyboard-quit)
;(map-normal key minibuffer-local-must-match-map [escape] 'keyboard-quit)
;(map-normal key minibuffer-local-isearch-map [escape] 'keyboard-quit)

;; dired
(setq default-directory "~/projects")
(require 'dired)
(map-leader "d" 'dired-jump)
(evil-define-key 'normal dired-mode-map "u" 'dired-up-directory)
(evil-define-key 'normal dired-mode-map "j" 'evil-next-line)
(evil-define-key 'normal dired-mode-map "k" 'evil-previous-line)
(evil-define-key 'normal dired-mode-map "l" 'evil-forward-char)
(evil-define-key 'normal dired-mode-map "J" 'dired-goto-file)
(evil-define-key 'normal dired-mode-map "K" 'dired-do-kill-lines)
(evil-define-key 'normal dired-mode-map "r" 'dired-do-redisplay)
(evil-define-key 'normal dired-mode-map " " leader-map)
(evil-define-key 'normal dired-mode-map "n" 'evil-search-next)
(evil-define-key 'normal dired-mode-map "N" 'evil-search-previous)
(evil-define-key 'normal dired-mode-map "L" 'evil-window-bottom)
(evil-define-key 'normal dired-mode-map "M" 'evil-window-middle)
(evil-define-key 'normal dired-mode-map "H" 'evil-window-top)
(evil-define-key 'normal dired-mode-map (kbd "<escape>") 'delete-window)

;; noises
(setq ring-bell-function 'ignore)

;; occur
(map-leader "/" 'occur)

;; emmet
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.

;; yasnippet
(require 'yasnippet)
(map-leader "sn" 'yas-new-snippet)
(map-leader "se" 'yas-visit-snippet-file)
(yas-global-mode 1)
(setq yas/triggers-in-field t); Enable nested triggering of snippets
(yas-load-directory "~/config/emacs/snippets/")
(setq yas/root-directory "~/config/emacs/snippets/")
(yas-load-directory yas/root-directory)
(yas-reload-all)
(setq-default mode-require-final-newline nil)
(add-hook 'yas-before-expand-snippet-hook
          #'(lambda()
              (when (evil-visual-state-p)
                (let ((p (point))
                      (m (mark)))
                  (evil-insert-state)
                  (goto-char p)
                  (set-mark m)))))

;; config config (metaconfig?)
(map-normal (kbd "<f1>") (lambda () (interactive) (load-file "~/config/dotfiles/emacs.el")))
(map-leader (kbd "<f1>") (lambda () (interactive) (find-file "~/config/dotfiles/emacs.el")))

;; ace-jump
(require 'cl) ;required by ace-jump
(map-leader "f" 'ace-jump-mode);))

;; helm
(helm-mode)
(map-leader "b" 'helm-mini)

;; projectile
(projectile-global-mode 1)
(setq projectile-enable-caching t)
(map-leader "o" 'helm-projectile)
(map-leader "O" 'projectile-switch-project)
(add-hook 'projectile-switch-project-hook 'projectile-dired)

;; hide junk I don't want to see
;(setq mode-line-format nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq initial-scratch-message "")
(set-default 'truncate-lines t)
(setq make-backup-files nil)
(setq backup-directory-alist `(("." . "/tmp")))
(setq auto-save-default nil)

;; scrolling
(setq scroll-margin 0)
(setq scroll-conservatively 10000)
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-progressive-speed t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; indentation
(global-set-key (kbd "RET") 'reindent-then-newline-and-indent)
(setq whitespace-style '(trailing tabs newline tab-mark newline-mark))
(setq indent-line-function 'insert-tab)
(setq c-basic-indent 2)
(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq show-trailing-whitespace t)
;(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; color schemes
;(load-theme 'solarized-light t)
;(load-theme 'solarized-dark t)
;(load-theme 'zenburn t)
;(load-theme 'wombat t)
;(load-theme 'misterioso)
;(load-theme 'anti-zenburn t)
;(load-theme 'noctilux t)
(load-theme 'dichromacy t)


;; minor modes
(electric-pair-mode 1) ;generate the matching pair
(setq show-paren-delay 0.0) (show-paren-mode 1) ;highlight the matching paren
(column-number-mode 1) ;show column numbers

;; linum
(global-linum-mode 1) ;show line numbers

;; font
(map-normal (kbd "C-=") 'text-scale-adjust)
(map-normal (kbd "C--") 'text-scale-adjust)
(map-normal (kbd "C-0") 'text-scale-adjust)
(setq-default line-spacing 3)
(mapc (lambda (face)
  (set-face-attribute face nil :weight 'normal :underline nil))
    (face-list))

;; js
(setq js-expr-indent-offset 2)
(setq js-indent-level 2)
(setq js-paren-indent-offset 2)
(setq js-square-indent-offset 2)

;; osx specific config
(setq locate-command "mdfind")

;; eshell
(require 'eshell)
(map-leader "." (lambda ()
  (interactive)
  (split-window-vertically)
  (windmove-down)
  (eshell)))
(add-hook 'eshell-mode-hook '(lambda ()
  (toggle-truncate-lines nil)
  (define-key eshell-mode-map (kbd "C-p") 'eshell-previous-input)
  (define-key eshell-mode-map (kbd "C-n") 'eshell-next-input)
  (define-key eshell-mode-map (kbd "C-r") 'rename-buffer)
  (define-key eshell-mode-map (kbd "C-k") (lambda () (eshell-reset)))
  (define-key eshell-mode-map (kbd "<escape>") 'delete-window)
  (define-key eshell-mode-map (kbd "S-<escape>") (lambda () (interactive) (kill-this-buffer) (delete-window)))
  (linum-mode -1)))

;; misc key mappings
(map-leader " " (lambda ()
  (interactive)
  (set-buffer-modified-p t)
  (save-buffer)))
(map-normal "Y" 'copy-to-end-of-line)
(map-normal "0" 'evil-first-non-blank)
(map-normal "Q" 'mark-whole-buffer)
(map-normal "K" (lambda () (interactive)))
(map-normal "*" (lambda ()
                  (interactive)
                  (save-window-excursion
                    (evil-search-symbol-forward)
                    (evil-search-previous))))

;; misc settings
(setq vc-follow-symlinks t)

;; windows
(map-leader "-" 'split-window-vertically)
(map-leader "=" 'split-window-horizontally)
(map-leader "l" 'windmove-right)
(map-leader "h" 'windmove-left)
(map-leader "j" 'windmove-down)
(map-leader "k" 'windmove-up)
(map-leader "wo" 'delete-other-windows)
(map-leader "wc" 'delete-window)
(map-leader "w=" 'balance-windows)

;; buffers
(map-leader "B" 'buffer-menu)
(map-leader "r" 'rename-buffer)
(map-leader "q" (lambda () (interactive) (kill-this-buffer)))

;; git and magit
(map-leader "gs" 'magit-status)
(map-leader "gb" 'magit-blame-mode)
(add-hook 'magit-mode-hook (lambda () (define-key magit-mode-map " " leader-map)))
(setq magit-default-tracking-name-function 'magit-default-tracking-name-branch-only)

;; git gutter
(require 'git-gutter-fringe)
;(setq git-gutter-fr:side 'right-fringe)
(setq git-gutter-fr:side 'left-fringe)
(map-leader "gg" 'git-gutter:toggle)
(map-normal "gn" 'git-gutter:next-hunk)
(map-normal "gp" 'git-gutter:previous-hunk)
(map-normal "gr" 'git-gutter:revert-hunk)
(setq left-fringe-width 8)
(setq right-fringe-width 3)
(setq git-gutter:hide-gutter t)
(setq git-gutter:update-threshold 1)
(setq git-gutter:update-hooks '(after-save-hook after-revert-hook))
;(add-hook 'post-command-hook 'git-gutter:update-diffinfo)

(setq git-gutter:hide-gutter t)
(setq git-gutter:update-threshold 1)
(setq git-gutter:update-hooks '(after-save-hook after-revert-hook))

(fringe-helper-define 'git-gutter-fr:added nil
  "...xx..."
  "...xx..."
  "...xx..."
  "xxxxxxxx"
  "xxxxxxxx"
  "...xx..."
  "...xx..."
  "...xx...")

(fringe-helper-define 'git-gutter-fr:deleted nil
  "xx....xx"
  "xxx..xxx"
  ".xx..xx."
  "..xxxx.."
  "..xxxx.."
  ".xx..xx."
  "xxx..xxx"
  "xx....xx")

(fringe-helper-define 'git-gutter-fr:modified nil
  "........"
  ".xxxxxx."
  ".xxxxxx."
  ".xx..xx."
  ".xx..xx."
  ".xxxxxx."
  ".xxxxxx."
  "........")

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

;; frames
(map-leader "tN" 'make-frame)
;(map-normal "gt" (lambda() (interactive) (other-frame  1)))
;(map-normal "gT" (lambda() (interactive) (other-frame -1)))
;(map-leader "tc" 'delete-frame)
;(map-leader "to" 'delete-other-frames)

;; tabs (with elscreen)
(require 'elscreen)
(elscreen-start)
(setq elscreen-display-tab nil)
(setq elscreen-tab-display-control nil)
(setq elscreen-start)
(map-leader "tn" 'elscreen-create)
(map-leader "tc" 'elscreen-kill)
(map-leader "to" 'elscreen-kill-others)
(map-leader "tl" 'helm-elscreen)
(map-normal "gt" 'elscreen-next)
(map-normal "gT" 'elscreen-previous)

;; fill column indicator
;(setq fci-rule-column 100)
;(fci-mode 1)

;;temporary files
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; minimap
(setq minimap-always-recenter t)
(setq minimap-dedicated-window t)
(setq minimap-window-location 'right)

;; languages

;; compiler c++
(setq compile-command "make")
(defun my-recompile ()
  "Run compile and resize the compile window closing the old one if necessary"
  (interactive)
  (progn
    (save-buffer)
    (if (get-buffer "*compilation*") ; If old compile window exists
        (progn
          (delete-windows-on (get-buffer "*compilation*")) ; Delete the compilation windows
          (kill-buffer "*compilation*")) ; and kill the buffers
      (progn
        (call-interactively 'recompile)
        (enlarge-window 20)))))

(defun my-next-error ()
  "Move point to next error and highlight it"
  (interactive)
  (progn
    (next-error)
    (end-of-line-nomark)
    (beginning-of-line-mark)))

(defun my-previous-error ()
  "Move point to previous error and highlight it"
  (interactive)
  (progn
    (previous-error)
    (end-of-line-nomark)
    (beginning-of-line-mark)))

(map-leader "m" 'my-recompile)
(map-leader "M" 'compile)
(map-leader "n" 'my-next-error)
(map-leader "p" 'my-previous-error)

;; common
(defun language-common ()
  "Defines the settings that are common to all
  languages but must still be run in a hook"
  (interactive)
  (indent-tabs-mode nil)
  (setq evil-shift-width 2))

;; javascript
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(setq js-indent-level 2)
(add-hook 'javascript-mode-hook (lambda () (language-common)))

;; elisp
(add-hook 'elisp-mode-hook (lambda () (language-common)))

;; haskell
(add-hook 'haskell-mode-hook (lambda () (setq evil-auto-indent nil)))

;; erlang
(add-hook 'erlang-mode-mook (lambda ()
  (setq evil-auto-indent nil)))
;todo: move this into the hook
(map-leader "m" 'erlang-compile)

(add-hook 'erlang-shell-mode-hook (lambda ()
  (define-key erlang-shell-mode-map (kbd "<escape>") 'delete-window)
  (define-key erlang-shell-mode-map (kbd "S-<escape>") (lambda ()
    (interactive)
    (kill-this-buffer)
    (delete-window)))))

;; social
;; twitter
(map-leader "st" 'twit)
(setq twittering-icon-mode t)
(setq twittering-use-master-password t)

;; bitlbee
(map-leader "sg" (lambda ()
  (interactive)
  (erc :server "localhost" :port 6667 :nick "j")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(emmet-indentation 2)
 '(emmet-preview-default nil)
 '(global-linum-mode t)
 '(js2-basic-offset 2)
 '(js2-missing-semi-one-line-override t)
 '(menu-bar-mode nil)
 '(mode-require-final-newline nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(yas-also-auto-indent-first-line t)
 '(yas-global-mode t nil (yasnippet))
 '(yas-indent-line (quote auto))
 '(yas-snippet-dirs "~/config/emacs/snippets/" nil (yasnippet))
 '(yas-triggers-in-field t)
 '(yas-wrap-around-region t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight thin :height 140 :width normal :foundry "apple" :family "Source_Code_Pro"))))
 '(emmet-preview-output ((t nil)))
 '(fringe ((t (:background "#ffffff"))))
 '(git-gutter-fr:added ((t (:foreground "orange1" :weight bold))))
 '(git-gutter-fr:deleted ((t (:foreground "MediumOrchid1" :weight bold))))
 '(git-gutter-fr:modified ((t (:foreground "turquoise1" :weight bold))))
 '(js2-external-variable ((t nil)))
 '(linum ((t (:background "#ffffff" :foreground "#cccccc" :slant normal))))
 '(mode-line ((t (:background "#b2cce6" :foreground "333333" :box (:line-width -1 :color "#555555" :style released-button)))))
 '(mode-line-inactive ((t (:inherit mode-line :background "#f8f8f8" :foreground "steelblue" :box (:line-width -1 :color "#bed6eb" :style released-button)))))
 '(vertical-border ((t (:foreground "#e0e0e0")))))
