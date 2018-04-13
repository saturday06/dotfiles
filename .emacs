; -*- coding: us-ascii-dos -*-

(message "===== '.emacs' begin =====")

; ----------------------------------------------------------------------------
; compatibility

(if (not (fboundp 'unless))
    (defmacro unless (condition &rest body)
      "unless"
      `(if (not ,condition) ,@body)))

(unless (fboundp 'when)
  (defmacro when (condition &rest body)
    "when"
    `(if ,condition (progn ,@body))))

(unless (fboundp 'push)
  (defmacro push (newelt listname)
    "push"
    `(setq ,listname (cons ,newelt ,listname))))

(unless (fboundp 'first)
  (defun first (l)
    "first"
    (car l)))

(unless (fboundp 'rest)
  (defun rest (l)
    "rest"
    (cdr l)))

(unless (fboundp 'executable-find)
  (defun executable-find (program)
    "executable-find"
    nil))

(unless (fboundp 'url-retrieve-synchronously)
  (defun url-retrieve-synchronously (url)
    "url-retrieve-synchronously"
    (let ((buffer (get-buffer-create (generate-new-buffer-name " *url-retrieve-synchronously*"))))
      (shell-command (concat "wget -q --save-headers -O- " url) buffer)
      buffer)))

(mapcar
 #'(lambda (pair)
    (unless (boundp (car pair))
      (set (car pair) (car (cdr pair)))))
 '((window-system nil)
   (window-system-version 0)
   (magic-mode-alist nil)
   (backup-directory-alist nil)
   (package-archives nil)
   ))

; ----------------------------------------------------------------------------
; http://www.sodan.org/~knagano/emacs/dotemacs.html

(defmacro defun-add-hook (hookname &rest sexplist)
  "defun add hook"
  `(add-hook ,hookname (function (lambda () ,@sexplist))))

(defmacro eval-safe-main (echo-on &rest body)
  "eval safe main"
  `(condition-case err (progn ,@body)
     (error (if ,echo-on (message "[eval-safe] %s" err)) nil)))

(defmacro eval-safe (&rest body)
  "eval safe"
  `(eval-safe-main t ,@body))

(defmacro eval-safe-no-echo (&rest body)
  "eval safe no echo"
  `(eval-safe-main nil ,@body))

(defmacro exec-if-bound (sexplist)
  "exec if bound"
  `(if (fboundp (car ',sexplist)) (eval-safe ,sexplist)))

(defun load-safe (loadlib)
  "load safe"
  (eval-safe
   (let ((load-status (load loadlib t)))
     (or load-status
         (message (format "[load-safe] failed %s" loadlib)))
     load-status)))

; make missing required dir
(mapcar
 #'(lambda (dir)
     (let ((abs-dir (expand-file-name (concat "~/.emacs.d/" dir))))
       (progn
         (unless (file-directory-p abs-dir)
           (make-directory abs-dir t))
         (push abs-dir load-path))))
 '(
   ".eshell"
   "backup"
   "lisp"
   "lisp/auto-complete"
   "lisp/customize"
   "lisp/dtrt-indent"
   "lisp/mmm"
   "lisp/rhtml"
   "semanticdb"
   "tmp"
   "usr/bin"
   ))

; setup PATH
(mapcar
 #'(lambda (path)
     (let ((full-path (expand-file-name path))
           (path-separator (if (featurep 'dos-w32) ";" ":")))
       (push full-path exec-path)
       (eval-safe
        (setenv "PATH" (concat (getenv "PATH") path-separator full-path)))))
 '(
   "~/.emacs.d/usr/bin"
   "~/.local/bin"
   "~/usr/bin"
   ))

; setup package-archives
(mapcar
 #'(lambda (package-archive)
     (push package-archive package-archives))
 '(
   ("gnu" . "https://elpa.gnu.org/packages/")
   ("melpa" . "http://melpa.org/packages/")
;   ("melpa-stable" . "http://stable.melpa.org/packages/")
;   ("elpa" . "http://tromey.com/elpa/")
;   ("marmalade" . "http://marmalade-repo.org/packages/")
   ))

; setup customization
(eval-safe
 (setq filename system-configuration)
 (unless window-system
   (setq filename (concat filename ".console")))
 (setq filename (concat filename "@" (system-name)))
 (while (string-match "[^-a-zA-Z0-9._@]" filename)
   (setq filename (replace-match "." nil nil filename)))
 (setq custom-file (concat "~/.emacs.d/lisp/customize/" filename ".el"))
 (if (file-exists-p custom-file) (load custom-file))
 )

; ----------------------------------------------------------------------------
; keyboards

; \C-h => backspace
(global-set-key "\C-h" 'delete-backward-char)

; ----------------------------------------------------------------------------
; variable configuration

(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq initial-major-mode (if (fboundp 'default-generic-mode) 'default-generic-mode 'fundamental-mode))
(setq initial-scratch-message "")
(setq next-line-add-newlines nil)
(setq ring-bell-function '(lambda ()))
(setq tab-width 2)
(setq temporary-file-directory "~/.emacs.d/tmp/")
(setq x-select-enable-clipboard t)
(setq redisplay-dont-pause t)
(setq eshell-history-file-name "~/.emacs.d/.eshell/history")
(setq ruby-insert-encoding-magic-comment nil)
(setq completion-show-help nil)
(setq diff-switches "-u")
(setq load-home-init-file t) ; .emacs for XEmacs
(setq auto-save-buffers-enhanced-activity-flag nil)
(setq auto-save-buffers-enhanced-activitiy-flag nil) ; typo?
(setq make-backup-files t)
(setq backup-directory-alist `((".*" . ,(expand-file-name "~/.emacs.d/backup"))))
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "~/.emacs.d/backup") t)))
(setq auto-save-visited-file-name t)
(setq version-control t)
(setq inhibit-startup-screen t)
(setq kept-old-versions 50)
(setq kept-new-versions 50)
(setq delete-old-versions t)
(setq default-tab-width 2)
(setq indent-tabs-mode nil)
(unless (executable-find "sass") (setq scss-compile-at-save nil))

(setq-default c-basic-offset 2)
(setq-default c-default-style "k&r")
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)
(setq-default indent-level 2)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default truncate-lines t)
(setq-default truncate-partial-width-windows t)

(setq my-ime-cursor-color "red")
(setq my-default-cursor-color "black")

; ----------------------------------------------------------------------------
; put!

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

; ----------------------------------------------------------------------------
; configuration functions

(exec-if-bound (column-number-mode t))
(exec-if-bound (line-number-mode t))
(exec-if-bound (windmove-default-keybindings))
(exec-if-bound (show-paren-mode t))
(exec-if-bound (partial-completion-mode t))
(exec-if-bound (transient-mark-mode t))
(exec-if-bound (delete-selection-mode 1))
(exec-if-bound (global-font-lock-mode t))
(exec-if-bound (set-message-beep 'silent))
(exec-if-bound (mac-set-input-method-parameter 'roman 'cursor-color my-default-cursor-color))
(exec-if-bound (mac-set-input-method-parameter 'japanese 'cursor-color my-ime-cursor-color))

; ----------------------------------------------------------------------------
; GUI

(when window-system
  (exec-if-bound (tool-bar-mode -1))
  (exec-if-bound (menu-bar-mode 1))
  (exec-if-bound (set-scroll-bar-mode 'right))

  (eval-safe (set-specifier default-toolbar-visible-p nil))
  (eval-safe (set-specifier bottom-toolbar-visible-p nil))
  (eval-safe (set-specifier left-toolbar-visible-p nil))
  (eval-safe (set-specifier right-toolbar-visible-p nil))
  (eval-safe (set-specifier top-toolbar-visible-p nil))
  (eval-safe (set-specifier default-gutter-visible-p nil))

  ;; right-click menu
  (defun bingalls-edit-menu (event)
    (interactive "e")
    (popup-menu menu-bar-edit-menu)
    )
  (global-set-key [mouse-3] 'bingalls-edit-menu) ;;; note=2, wheel=3
  )

(when (featurep 'dos-w32)
  (eval-safe
   (set-default-coding-systems 'utf-8)
   ))

; --------------------------------------------------------------------
; CUI
(unless window-system
  (exec-if-bound (menu-bar-mode -1))
  )

; --------------------------------------------------------------------
; packages
(eval-safe
 (require 'package)
 (package-initialize)
 (let ((stamp-path "~/.emacs.d/package-refresh-contents-stamp"))
   (let ((mtime (nth 5 (file-attributes stamp-path))))
     (if (or (not mtime)
             (< (+ (time-to-seconds mtime) (* 7 24 60 60))
                (time-to-seconds (current-time)))
             )
         (progn
           (with-temp-buffer
             (insert "timestamp")
             (write-file stamp-path))
           (package-refresh-contents)
           ))))
 (unless (fboundp 'intero-mode)
   (package-install 'intero)
   (eval-safe
    (require 'intero)
    (add-hook 'haskell-mode-hook 'intero-mode)
    )
   )
 )

; ---
(eval-safe
 (require 'auto-save-buffers)
 (run-with-idle-timer 0.5 t 'auto-save-buffers)
 )

(eval-safe
 (require 'company)
 (setq company-idle-delay 0.2)
 (setq company-minimum-prefix-length 0)
 (setq company-selection-wrap-around t)
 (setq company-auto-expand t)
 ;(setq company-transformers '(company-sort-by-backend-importance))
 (setq completion-ignore-case t)
 (setq company-dabbrev-downcase nil)
 (global-set-key (kbd "C-M-i") 'company-complete)
 (define-key company-active-map (kbd "C-n") 'company-select-next)
 (define-key company-active-map (kbd "C-p") 'company-select-previous)
 (define-key company-active-map [tab] 'company-complete-selection)
 (define-key company-active-map (kbd "C-h") nil)
 (define-key company-active-map (kbd "C-S-h") 'company-show-doc-buffer)
 
 (require 'company-quickhelp)
 )

(eval-safe
 (require 'rust-mode)
 (defun rust-mode-hooks ()
   (if (fboundp 'company-indent-or-complete-common)
       (progn
         (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
         (setq company-tooltip-align-annotations t)
         ))
   (eval-safe (racer-mode))
   (eval-safe (eldoc-mode))
   (eval-safe
    (flycheck-mode)
    (flycheck-rust-setup))
   (eval-safe
    (company-mode)
    (company-quickhelp-mode))
   )
 (add-hook 'rust-mode-hook 'rust-mode-hooks)
 )

(defun save-macro (name)
  "save a macro. Take a name as argument
     and save the last defined macro under
     this name at the end of your .emacs"
  (interactive "SName of the macro: ")  ; ask for the name of the macro
  (kmacro-name-last-macro name)         ; use this name for the macro
  (find-file user-init-file)            ; open ~/.emacs or other user init file
  (goto-char (point-max))               ; go to the end of the .emacs
  (newline)                             ; insert a newline
  (insert-kbd-macro name)               ; copy the macro
  (newline)                             ; insert a newline
  (switch-to-buffer nil))               ; return to the initial buffer

; ----------------------------------------------------------------------------

(message "===== '.emacs' end =====")
(message "") ; clear Minibuffer

