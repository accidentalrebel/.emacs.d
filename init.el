;; -*- mode: emacs-lisp; coding: utf-8 -*-

;;; boot sequence
;; site-start.el --> .emacs --> default.el and terminal type file.

;; I use the Common Lisp stuff all the time
(require 'cl-lib)

;; First, avoid the evil:
(when (featurep 'xemacs)
  (error "This .emacs file (probably) does not work with XEmacs."))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; what kind of system are we using?  start with these, as it will influence
;; other stuff inspired by: http://www.xsteve.at/prg/emacs/.emacs.txt
(defconst win32-p (eq system-type 'windows-nt)
  "Are we running on a WinTel system?")
(defconst linux-p (or (eq system-type 'gnu/linux) (eq system-type 'linux))
  "Are we running on a GNU/Linux system?")
(defconst mac-p (eq system-type 'darwin) "Are we running on Macintosh system?")
(defconst console-p (eq (symbol-value 'window-system) nil)
  "Are we running in a console (non-X) environment?")


(setq emacs-load-start-time (current-time))
(setq debug-on-error t)                 ;will be cleared at end of buffer
;; http://pages.sachachua.com/.emacs.d/Sacha.html
;; While edebugging, use T to view a trace buffer (*edebug-trace*). Emacs will quickly execute the rest of your code,
;; printing out the arguments and return values for each expression it evaluates.
(setq edebug-trace t)

;;;  Load Path stuff
(unless (boundp 'user-emacs-directory)
  (defvar user-emacs-directory "~/.emacs.d/"
    "Directory beneath which additional per-user Emacs-specificfiles are placed. Various programs in
  Emacs store information in this directory. Note that this should end with a directory separator.
  See also `locate-user-emacs-file'."))

(defvar user-package-directory (concat user-emacs-directory "packages/"))

(add-to-list 'load-path user-package-directory)
(add-to-list 'load-path "~/.emacs.d/lisp/")


(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((default-directory (expand-file-name "~/.emacs.d/packages/")))
      ;; If you only want some of the subdirectories added you can use
      ;; (normal-top-level-add-to-load-path '("cedet"))
      (normal-top-level-add-subdirs-to-load-path)))


;;; load custom file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file 'noerror))


;;; temporary fix bug
;; Symbol's function definition is void: gui-selection-exists-p
(defalias 'gui-selection-exists-p 'x-selection-exists-p)

;; when el-get initialize ace-window, it'll compain can not find ace-jump-mode
(let ((p (expand-file-name"~/.emacs.d/el-get/ace-jump-mode")))
  (when (file-exists-p p)
    (add-to-list 'load-path p)))

(require '00site-start)
;; (mapc 'load (directory-files "~/.emacs.d/site-lisp" t "\.el$"))


;; A fun startup message, somewhat reminiscent of "The Matrix: Reloaded"
(defconst animate-n-steps 3)
(defun emacs-reloaded ()
  (animate-string (concat ";; Initialization successful, welcome to "
                          (substring (emacs-version) 0 16) ".") 0 0)
  (newline-and-indent) (newline-and-indent))

(add-hook 'after-init-hook 'emacs-reloaded)

(setq debug-on-error nil)                 ; was set to t at top of buffer

(when (require 'time-date nil t)
  (message "Emacs startup time: %d seconds." (time-to-seconds (time-since emacs-load-start-time))))

;;; init end there
