;;; 05cc-mode.el ---
;; Author: Shihpin Tsing <deftsp@gmail.com>
;; Time-stamp: <2012-05-26 18:20:26 Shihpin Tseng>


(let ((cc-mode-dir (expand-file-name "~/.emacs.d/lisp/cc-mode")))
  (when (file-directory-p cc-mode-dir)
    (add-to-list 'load-path cc-mode-dir)))

(eval-after-load "info"
  '(pushnew (expand-file-name "~/.emacs.d/lisp/cc-mode") Info-default-directory-list :test #'equal))

(eval-after-load "cc-mode"
  '(progn
     (require 'ifdef)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;make a #define be left-aligned
(setq c-electric-pound-behavior (quote (alignleft)))
;; variable: comment-padding Padding string that `comment-region' puts between comment chars and text.



(defun pl/next-c-function ()
  "Go to start of next C function."
  (interactive)
  (c-beginning-of-defun -1))

(defun pl/prev-c-function ()
  "Go to start of next C function."
  (interactive)
  (c-beginning-of-defun 2))




;;; doxymacs
(defun pl/doxymacs-font-lock-hook ()
  (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
      (doxymacs-font-lock)))

(eval-after-load "doxymacs"
  '(progn
     (add-hook 'font-lock-mode-hook 'pl/doxymacs-font-lock-hook)
     (add-hook 'c-mode-common-hook 'doxymacs-mode)))

;;; doxymacs end here -----


;;; ctypes
(defun pl/ctypes-load-hook ()
  (ctypes-read-file "~/.ctypes_std_c" nil t t))

(eval-after-load "cc-mode"
  '(progn
     (require 'ctypes)                     ; beautify typedefs
     (ctypes-auto-parse-mode 1)
     (add-hook 'ctypes-load-hook 'pl/ctypes-load-hook)))




;; style I want to use in c++ mode
(c-add-style "palory"
             '((indent-tabs-mode . nil)        ; use spaces rather than tabs
               (c-basic-offset . 4)            ; indent by four spaces
               (c-comment-only-line-offset . 0)
               (c-offsets-alist
                (statement-block-intro . +)
                (substatement-open . 0)
                (substatement-label . 0)
                (label . 0)
                (statement-cont . +)
                (inline-open . 0))))


(eval-after-load "cc-mode"
  '(progn
     (define-key c-mode-base-map (kbd "C-m") 'c-context-line-break) ; Do a line break suitable to the context.
     ;; (define-key c-mode-base-map (kbd "H-M-j") 'pl/move-function-down)
     ;; (define-key c-mode-base-map (kbd "H-M-k") 'pl/move-function-up)
     ;; ifdef - Parse the #if...#elif...#else...#endif block in a C file.
     (local-set-key (kbd "<M-S-iso-lefttab>") 'mark-ifdef)))


(defun pl/c-mode-common-hook ()
  ;; the delete key gobbles all preceding whitespace in one fell swoop
  (c-toggle-hungry-state 1))


(defun pl/c-mode-hook ()
  ;; (local-set-key [(control tab)] 'tempo-forward-mark)    ; move to next tempo mark
  (pl/outline-local-set-regexp pl/c-mode-common-outline-regexp)
  (c-set-style "palory"))


(defun pl/objc-mode-hook ()
  (c-set-style "palory")
  (define-key objc-mode-map (kbd "C-c C-r") 'xcode:build-and-run))


(defun pl/cpp-mode-hook ()
  (pl/outline-local-set-regexp pl/c-mode-common-outline-regexp)
  (c-set-style "palory"))

(add-hook 'c-mode-common-hook 'pl/c-mode-common-hook)
(add-hook 'c-mode-hook 'pl/c-mode-hook)
(add-hook 'c++-mode-hook 'pl/cpp-mode-hook)
(add-hook 'objc-mode-hook 'pl/objc-mode-hook)

;;; ff-find-other-file and friends

(eval-after-load "find-file"
  '(progn
     (push ".m" (cadr (assoc "\\.h\\'" cc-other-file-alist)))
     (push ".mm" (cadr (assoc "\\.h\\'" cc-other-file-alist)))
     (push '("\\.m\\'" (".h")) cc-other-file-alist)
     (push '("\\.mm\\'" (".h")) cc-other-file-alist)))


(defadvice ff-get-file-name (around ff-get-file-name-framework
                                    (search-dirs
                                     fname-stub
                                     &optional suffix-list))
  "Search for Mac framework headers as well as POSIX headers."
  (or
   (if (string-match "\\(.*?\\)/\\(.*\\)" fname-stub)
       (let* ((framework (match-string 1 fname-stub))
              (header (match-string 2 fname-stub))
              (fname-stub (concat framework ".framework/Headers/" header)))
         ad-do-it))
   ad-do-it))
(ad-enable-advice 'ff-get-file-name 'around 'ff-get-file-name-framework)
(ad-activate 'ff-get-file-name)

(when (eq system-type 'darwin)
  (setq cc-search-directories '("." "../include" "/usr/include" "/usr/local/include/*"
                                "/System/Library/Frameworks" "/Library/Frameworks")))


(eval-after-load "cc-mode"
  '(define-key c-mode-base-map (kbd "C-c S") 'ff-find-other-file))



;;;
;; move current function up
(defun pl/move-function-up ()
  (interactive)
  (save-excursion
    (c-mark-function)
    (kill-region (region-beginning) (region-end))
    (c-beginning-of-defun 1)
    (yank)))

;; move current function down
(defun pl/move-function-down ()
  (interactive)
  (save-excursion
    (c-mark-function)
    (kill-region (region-beginning) (region-end))
    (c-beginning-of-defun -1)
    (yank)))
;; Probably you you can use 'delete-and-extract-region' instead of 'kill-region' plus 'yank'.

;;----------------------------------------------------------------------------------------------------

;; (defun mark-c-scope-beg ()
;;   "Marks the c-scope (region between {}) enclosing the point.
;;    Naive, as will be confused by { } within strings"
;;   (let
;;    ((scope-depth 1))
;;  (while (not (= scope-depth 0))
;;    (search-backward-regexp "}\\|{")
;;    (if (string= (char-to-string (char-before)) "}")
;;        (setq scope-depth (1+ scope-depth))
;;          (setq scope-depth (1- scope-depth)))))
;;   (point))

;; (defun mark-c-scope-end ()
;;   "Marks the c-scopie (region between {}) enclosing the point.
;;    Naive, as will be confused by { } within strings"
;;   (let
;;    ((scope-depth 1))
;;  (while (not (= scope-depth 0))
;;    (search-forward-regexp "}\\|{")
;;    (if (string= (char-to-string (char-before)) "}")
;;        (setq scope-depth (1- scope-depth))
;;          (setq scope-depth (1_ scope-depth)))))
;;   (point))

;; (defun kill-c-scope ()
;;   (interactive)
;;   (let
;;    ((inital-point (point)))
;;  (save-excursion
;;    (let
;;      ((beg (mark-c-scope-beg)))
;;      (goto-char inital-point)
;;      (let ((end (mark-c-scope-end))))))))

;;; Comment
;; (setq comment-start "//")
;; (setq compilation-read-command 'nil)
(setq comment-style 'extra-line)        ;default "indent"

;;; font-lock
(defun pl/add-c-common-mode-font-lock-keywords ()
  (dolist (m '(c-mode objc-mode c++-mode))
    ;; Colorisation : C/C++/Object-C : Commentaires
    (font-lock-add-keywords m '(("\\<\\(FIXME\\):" 1 font-lock-warning-face prepend)
                                ("\\<\\(TODO\\):" 1 font-lock-warning-face prepend)
                                ("\\<\\(td_[-.a-z0-9_]*;?\\)\\>" . font-lock-builtin-face)
                                ("\\<\\(WARNING\\)" 1 font-lock-warning-face t)
                                ("\\<\\(NOTE\\)" 1 font-lock-warning-face t)
                                ("\\<\\(NOTES\\)" 1 font-lock-warning-face t)
                                ("\\<\\(DEBUG\\)" 1 font-lock-warning-face t)
                                ("\\<\\(OUTPUT\\)" 1 font-lock-warning-face t)
                                ("\\<\\(IMPORTANT\\)" 1 font-lock-warning-face t)
                                ;; highlight line that are too long
                                ("^[^\n]\\{80\\}\\(.*\\)$" 1 font-lock-warning-face t)))))

(eval-after-load "cc-mode"
  (progn
    (pl/add-c-common-mode-font-lock-keywords)
    (dolist (type (list "UCHAR" "USHORT" "ULONG" "BOOL" "BOOLEAN" "LPCTSTR" "C[A-Z]\\sw+" "\\sw+_t"))
      (add-to-list 'c-font-lock-extra-types type))))


;; Colorisation : C : Grands classiks
;; (font-lock-add-keywords 'c-mode
;;                         '(("\\<\\(string\\)\\>" . font-lock-type-face)
;;                           ("\\<\\(vector\\)\\>" . font-lock-type-face)
;;                           ("\\<\\(namespace\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(class\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(virtual\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(printf\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(getc\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(strtok\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(strcmp\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(strlen\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(atoi\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fgets\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fprintf\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(remove\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(rename\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(stat\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(open\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(opendir\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(closedir\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fstat\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fopen\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(freopen\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fclose\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fflush\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(fpurge\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(feof\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(dlopen\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(dlsym\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(dlerror()\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(sleep;?\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(setenv;?\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(pthread_[-.a-z0-9_]*;?\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(sem_[-.a-z0-9_]*;?\\)\\>" . font-lock-keyword-face)
;;                           ;; Colorisation : Glib Gdk Gtk+ GNOME
;;                           ("\\<\\(g_[-.a-z0-9_]*;?\\)\\>" . font-lock-keyword-face)
;;                           ("\\<\\(gdk_[-.a-z0-9_]*;?\\)\\>" . font-lock-constant-face)
;;                           ("\\<\\(gtk_[-.a-z0-9_]*;?\\)\\>" . font-lock-constant-face)
;;                           ("\\<\\(gnome_[-.a-z0-9_]*;?\\)\\>" . font-lock-constant-face)
;;                           ("\\<\\(poptGetArgs\\)\\>" . font-lock-constant-face)
;;                           ))


;;; indent the entire buffer
(defun indent-entire-c-buffer ()
  "Indent entire buffer of C source code."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (< (point) (point-max))
      (c-indent-command)
      (end-of-line)
      (forward-char 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; "funky stuff"

;; The function above is funky but useful. Having swapped the pairs ('[', '{'), ('-', '_') and (']', '}'), in order to type
;; "->", we need to type four characters ('Shift' followed by '-' followed by 'Shift' followed by '>'). With the above
;; code, all you need to type is two underscores: '__'). Automagically, they are converted into '->'). Similarly, two
;; successive dots '..' are translated into '[]' (for array indexing). I find that these combinations improve my
;; code-typing speed significantly.

;; (defun my-editing-function (first last len)
;;   (interactive)
;;   (if (and (boundp 'major-mode)
;;            (member major-mode (list 'c-mode 'c++-mode 'gud-mode))
;;            (= len 0)
;;            (> (point) 4)
;;            (= first (- (point) 1)))
;;       (cond
;;        ((and (string-equal (buffer-substring (point) (- (point) 2)) "__")
;;              (not (string-equal (buffer-substring (point) (- (point) 3)) "___")))
;;         (progn (delete-backward-char 2) (insert-char ?- 1) (insert-char ?> 1)))

;;        ((string-equal (buffer-substring (point) (- (point) 3)) "->_")
;;         (progn (delete-backward-char 3) (insert-char ?_ 3)))

;;        ((and (string-equal (buffer-substring (point) (- (point) 2)) "..")
;;              (not (string-equal (buffer-substring (point) (- (point) 3)) "...")))
;;         (progn (delete-backward-char 2) (insert-char ?[ 1) (insert-char ?] 1) (backward-char 1)))

;;        ((and (> (point-max) (point))
;;              (string-equal (buffer-substring (+ (point) 1) (- (point) 2)) "[.]"))
;;         (progn (forward-char 1) (delete-backward-char 3) (insert-char ?. 1) (insert-char ?. 1) )))
;;     nil))

;; (add-hook 'after-change-functions 'my-editing-function)


;;----------------------------------------------------------------------------------------------------
;; jump out from a pair(like quote, parenthesis, etc.)
(defun pl/c-escape-pair ()
  (interactive)
  (let ((pair-regexp "[^])}\"'>]*[])}\"'>]"))
    (if (looking-at pair-regexp)
        (progn
          ;; be sure we can use C-u C-@ to jump back, if we goto the wrong place
          (push-mark)
          (goto-char (match-end 0)))
      (c-indent-command))))


(defun do-cdecl ()
  "Compose C and C++ type declarations"
  (interactive)
  (shell-command
   (concat "cdecl explain \"" (buffer-substring (region-beginning)
                                                (region-end)) "\"")))

(provide '05cc-mode)
