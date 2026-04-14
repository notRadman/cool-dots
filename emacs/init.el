;; ========================================
;; init.el — Emacs config (ported from Neovim)
;; Evil Mode + Vanilla, no frameworks
;; ========================================


;; ========== Package Manager (straight.el bootstrap) ==========
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package integration
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


;; ========== Appearance ==========
;;(use-package doom-themes
;;  :config
;;  (load-theme 'doom-monokai-pro t))   ;; closest theme to unokai

;; (set-frame-font "MonoLisa 13" nil t)  ;; change font if needed

(setq inhibit-startup-message t)      ;; no splash screen
(menu-bar-mode -1)                    ;; no menu bar
;;(tool-bar-mode -1)                    ;; no tool bar
;;(scroll-bar-mode -1)                  ;; no scroll bar
(global-display-line-numbers-mode t)  ;; line numbers
(setq display-line-numbers-type 'relative) ;; relative numbers like Neovim
(global-hl-line-mode t)               ;; highlight current line
(show-paren-mode t)                   ;; highlight matching brackets


;; ========== Transparent Background ==========
(set-frame-parameter nil 'alpha-background 90) ;; subtle transparency, adjust or remove


;; ========== Indentation ==========
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)   ;; spaces not tabs
(setq-default electric-indent-mode t)


;; ========== Search ==========
(setq search-upper-case nil)          ;; ignore case
(setq isearch-case-fold-search t)


;; ========== General ==========
(setq mouse-yank-at-point t)
(setq scroll-margin 8)                ;; scrolloff = 8 like Neovim
(setq scroll-conservatively 101)
(setq make-backup-files nil)          ;; no annoying backup files
(setq auto-save-default nil)
(setq ring-bell-function 'ignore)     ;; no bell
(setq-default fill-column 80)
(global-auto-revert-mode t)           ;; auto reload file if changed outside
(setq bidi-display-reordering t)      ;; bidirectional text support (termbidi)
(setq-default bidi-paragraph-direction 'nil)


;; ========== Encoding ==========
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)


;; ========== Evil Mode ==========
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)     ;; required for evil-collection
  (setq evil-want-C-u-scroll t)       ;; C-u scrolls like Vim
  (setq evil-undo-system 'undo-redo)  ;; proper undo/redo
  :config
  (evil-mode 1))

(use-package evil-collection          ;; evil keybindings for dired, magit, etc
  :after evil
  :config
  (evil-collection-init))


;; ========== Leader Key ==========
;; using , as leader key to match your old config
(use-package general
  :config
  (general-create-definer my-leader-def
    :states '(normal visual)
    :keymaps 'override
    :prefix ","))


;; ========== Buffer Navigation (like Tab / S-Tab) ==========
(general-define-key
 :states 'normal
 "<tab>"   'next-buffer
 "<S-tab>" 'previous-buffer)

(my-leader-def
  "x" 'kill-this-buffer)              ;; ,x kills current buffer


;; ========== Window Navigation (C-h/j/k/l) ==========
(general-define-key
 :states 'normal
 "C-h" 'windmove-left
 "C-l" 'windmove-right
 "C-j" 'windmove-down
 "C-k" 'windmove-up)


;; ========== Window Resizing (Space + h/j/k/l) ==========
(general-define-key
 :states 'normal
 "SPC h" (lambda () (interactive) (shrink-window-horizontally 3))
 "SPC l" (lambda () (interactive) (enlarge-window-horizontally 3))
 "SPC j" (lambda () (interactive) (shrink-window 3))
 "SPC k" (lambda () (interactive) (enlarge-window 3)))


;; ========== File Explorer (Dired) ==========
(use-package dired
  :straight nil                        ;; built-in
  :config
  (setq dired-listing-switches "-lhGF --group-directories-first")
  (setq dired-kill-when-opening-new-dired-buffer t)) ;; avoid buffer clutter

(my-leader-def
  "e" 'dired-jump)                     ;; ,e opens dired at current file location


;; ========== Git (Magit) ==========
(use-package magit
  :defer t)

(my-leader-def
  "g" 'magit-status)                   ;; ,g opens magit


;; ========== Compile Mode ==========
(my-leader-def
  "c" 'compile                         ;; ,c to compile
  "r" 'recompile)                      ;; ,r to recompile without prompt

(setq compilation-scroll-output t)     ;; auto scroll compilation output


;; ========== Completion (Vertico) ==========
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless                 ;; fuzzy matching regardless of word order
  :config
  (setq completion-styles '(orderless basic)))

(use-package marginalia                ;; descriptions next to completion candidates
  :init
  (marginalia-mode))


;; ========== Which Key ==========
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))


;; ========== Status Bar ==========
;;(use-package doom-modeline
;;  :init
;;  (doom-modeline-mode 1))


;; ========== Escape everything with Esc ==========
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
