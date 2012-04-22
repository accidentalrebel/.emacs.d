;; -*- mode: Emacs-Lisp -*-
;; Time-stamp: <2012-04-22 17:37:45 Shihpin Tseng>


(autoload 'gambit-inferior-mode "gambit" "Hook Gambit mode into cmuscheme.")
(autoload 'gambit-mode "gambit" "Hook Gambit mode into scheme.")
(add-hook 'inferior-scheme-mode-hook (function gambit-inferior-mode))
(add-hook 'scheme-mode-hook (function gambit-mode))
(setq scheme-program-name "gsi -:d-")   ; mzscheme



;; (define-key scheme-mode-map (kbd "\t") 'scheme-complete-or-indent)



;; (setqa scheme-mit-dialect nil)

;; Tell emacs about your special interpreters. This is from the #! line.
;; (add-to-list 'interpreter-mode-alist '("scsh" . scheme-mode))

;; (defun mit-scheme ()
;;     "Runs MIT scheme"
;;     (interactive)
;;     (run-scheme "athrun scheme scheme -emacs")
;;     (process-kill-without-query (get-process "scheme")))


;;; You want quack. Really.
;; http://alexott.net/en/writings/emacs-devenv/EmacsScheme.html
(require 'quack)
(setq quack-fontify-style 'emacs          ;or 'plt
      quack-default-program "gsi -:d-"
      quack-newline-behavior 'indent-newline-indent)


(eval-after-load "quack"
  '(progn
     (set-face-attribute quack-pltish-paren-face nil :foreground "#ccffcc" :weight 'normal)
     (set-face-attribute quack-pltish-comment-face nil :foreground "#008888" :weight 'normal)
     (set-face-attribute quack-pltish-keyword-face nil :foreground "#bbbb99" :weight 'bold)
     (set-face-attribute quack-pltish-selfeval-face nil :foreground "#a800a8")
     (set-face-attribute quack-pltish-defn-face nil :foreground "#ff7f00")
     (set-face-attribute quack-threesemi-semi-face nil :background 'unspecified)
     (set-face-attribute quack-threesemi-text-face nil :background 'unspecified)))

;; Examples for quick documentation access. Quack does similar stuff.
;; (defun s48-doc ()
;;  "Browse the Scheme48 documentation."
;;  (interactive)
;;  (browse-url "file:///usr/share/doc/scheme48/html/s48manual.html"))

;;(defun scsh-doc ()
;;  "Browse the scsh documentation."
;;  (interactive)
;; (browse-url "file:///usr/share/doc/scsh-doc/scsh-manual/html/man-Z-H-1.html"))

;;; Tell emacs about the indentation of some not-so-well-known
;;; procedures.

;; If you are running scheme48 download scheme48.el from
;; http://www.emacswiki.org/cgi-bin/wiki/Scheme48Mode
;; And add this provide
;(require 'scheme48)

;; gauche
;; (put 'with-error-handler 'scheme-indent-function 1)     ; 'defun)
;; (put 'with-exception-handler 'scheme-indent-function 1)
;; (put 'with-exit-exception-handler 'scheme-indent-function 1)
;; (put 'with-exit-exception-handler* 'scheme-indent-function 2)
;; (put 'my-with-exception-handler 'scheme-indent-function 2)
;; (put 'for-debug 'scheme-indent-function 'defun)
;; (put 'test-expected 'scheme-indent-function 'defun)
;; (put 'call-with-input-string 'scheme-indent-function 1)
;; (put 'with-port-locking 'scheme-indent-function 1)



;; ==================================================================
;; A customized indentation function for receive.
;; It is adapted from lisp-indent-specform.

;; This will indent RECEIVE as follows:
;; (receive params
;;          producer
;;   receiver)
;; instead of the `put' form above, which will indent as follows:
;; (receive params
;;     producer
;;   receiver)

;; Note: This could be made into a generalized function
;;   if it would be useful for other scheme functions.

;;============================================================================
;; (defun scheme-indent-receive (state indent-point normal-indent)
;;   (let ((containing-form-start (nth 1 state))
;;         (i 0)
;;         containing-form-column)
;;     ;; <snip documentation>
;;     (goto-char containing-form-start)
;;     (setq containing-form-column (current-column))
;;     (forward-char 1)
;;     (forward-sexp 1)
;;     ;; Now find the start of the last form.
;;     (parse-partial-sexp (point) indent-point 1 t)
;;     (while (and (< (point) indent-point)
;;                 (condition-case ()
;;                     (progn
;;                       (setq i (1+ i))
;;                       (forward-sexp 1)
;;                       (parse-partial-sexp (point) indent-point 1 t))
;;                   (error nil))))
;;     ;; Point is sitting on first character of last (or count) sexp.
;;     (cond ((= i 0)
;;            (+ containing-form-column (* 2 lisp-body-indent)))
;;           ((= i 1) normal-indent)
;;           (t (+ containing-form-column lisp-body-indent)))))

;; ;; tell emacs to use this function for indenting receive
;; (put 'receive 'scheme-indent-function 'scheme-indent-receive)


;;=======================================================================
;;; This is a *slightly* modified version of what is in scheme.el,
;;; which is itself a slight modification of `lisp-indent-function'
;;; from lisp-mode.el.  Gee, you'd think that someone would think of
;;; the notion of 'abstraction' here...

;; (defun scheme-indent-function (indent-point state)
;;   (let ((normal-indent (current-column)))
;;     (goto-char (1+ (elt state 1)))
;;     (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
;;     (if (and (elt state 2)
;;              (not (looking-at "\\sw\\|\\s_")))
;;         ;; car of form doesn't seem to be a symbol
;;         (progn
;;           (if (not (> (save-excursion (forward-line 1) (point))
;;                       calculate-lisp-indent-last-sexp))
;;               (progn (goto-char calculate-lisp-indent-last-sexp)
;;                      (beginning-of-line)
;;                      (parse-partial-sexp (point)
;;                                          calculate-lisp-indent-last-sexp 0 t)))
;;           ;; Indent under the list or under the first sexp on the same
;;           ;; line as calculate-lisp-indent-last-sexp.  Note that first
;;           ;; thing on that line has to be complete sexp since we are
;;           ;; inside the innermost containing sexp.
;;           (backward-prefix-chars)
;;           (current-column))
;;       (let ((function (downcase         ;** downcasage added by TRC
;;                        (buffer-substring (point)
;;                                          (progn (forward-sexp 1) (point)))))
;;             method)
;;         (setq method (or (get (intern-soft function) 'scheme-indent-function)
;;                          (get (intern-soft function) 'scheme-indent-hook)))
;;         (cond ((or (eq method 'defun)
;;                    (and (null method)
;;                         (> (length function) 3)
;;                         (string-match "\\`def" function)))
;;                (lisp-indent-defform state indent-point))
;;                                         ;** WITH-... & CALL-WITH-... forms added by TRC
;;               ((or (eq method 'with-...)
;;                    (eq method 'call-with-...)
;;                    (and (null method)
;;                         (or (and (> (length function) 5)
;;                                  (string-match "\\`with-" function))
;;                             (and (> (length function) 9)
;;                                  (string-match "\\`call-with-" function)))))
;;                (lisp-indent-withform state indent-point))
;;               ((integerp method)
;;                (lisp-indent-specform method state
;;                                      indent-point normal-indent))
;;               (method
;;                (funcall method state indent-point normal-indent)))))))


;;============================================================================
;++ This is an approximation.  It fails for something like:
;++   (with-foo bar
;++     baz (quux))
;++ It could be generalized to negative special form indent methods; e.g.,
;++   (put 'with-frobbotzim 'scheme-indent-function -2)
;++ and then
;++   (with-frobbotzim frob grovel
;++       full lexical
;++       mumble chumble
;++       spuzz
;++    (lambda (foo) ...)
;++    (lambda (bar) ...))
;++ That is, the last two subforms would be indented two spaces, whereas all
;++ preceding subforms would get four spaces.

;; (defun lisp-indent-withform (state indent-point)
;;   (if (not (and (boundp 'paredit-mode)
;;                 paredit-mode))
;;       ;; If we're not in paredit mode, it's not really safe to go backwards
;;       ;; from the end and to try to indent based on that, since there may not
;;       ;; be an end to work backwards from (i.e. the structure not be valid).
;;       (lisp-indent-defform state indent-point)
;;     (goto-char (nth 1 state))
;;     (let ((body-column (+ (current-column)
;;                           lisp-body-indent)))
;;       (forward-sexp 1)
;;       (backward-char 1)
;;       (backward-sexp 1)
;;       (skip-chars-backward " \t" (point-at-bol))
;;       (if (= (point) indent-point)
;;           body-column
;;           ;; If it's not the last argument, then we must specify not only the
;;           ;; column to indent to but also the start of the containing sexp,
;;           ;; which implies (don't ask me how) that any *following* subforms
;;           ;; must be indented separately, and not just on this column.  This
;;           ;; allows C-M-q to know to indent the penultimate arguments with four
;;           ;; spaces, but to keep recomputing the indentation so that it doesn't
;;           ;; assume the last one will go to the same column, which is a wrong
;;           ;; assumption.
;;           (list (+ body-column lisp-body-indent)
;;                 (nth 1 state))))))


;;======================================================================================

;;给cmuscheme.el加入执行命令时，自动启动scheme解释器，自动显示Scheme buffer。加
;;加入了scheme-send-line函数，并且绑定到 C-c C-c
;; (defun tsp-scheme-mode-hook ()
;;   (defun scheme-send-region (start end)
;;     "Send the current region to the inferior Scheme process."
;;     (interactive "r")
;;     (let ((origbuffer (current-buffer))
;;           (proc (get-buffer-process (if (eq major-mode 'inferior-scheme-mode)
;;                                         (current-buffer)
;; 				      scheme-buffer))))
;;       (or proc
;;           (progn
;;             (run-scheme scheme-program-name)
;;             (pop-to-buffer (process-buffer (scheme-proc)) t)
;;             (goto-char (point-max))
;;             (pop-to-buffer origbuffer))))

;;     (comint-send-region (scheme-proc) start end)
;;     (comint-send-string (scheme-proc) "\n")
;;     (scheme-display-buffer)))

;; (add-hook 'scheme-mode-hook 'tsp-scheme-mode-hook)

;; (defun scheme-display-buffer ()
;;   "Display the inferior-maxima-process buffer so the recent output is visible."
;;   (interactive)
;;   (let ((origbuffer (current-buffer)))
;;     (pop-to-buffer (process-buffer (scheme-proc)) t)
;;     (goto-char (point-max))
;;     (pop-to-buffer origbuffer)))

;; (defun scheme-send-line ()
;;   "Send the line to the inferior Scheme process."
;;   (interactive)
;;   (scheme-send-region
;;    (save-excursion
;;      (beginning-of-line) (point))
;;    (save-excursion
;;      (progn (end-of-line) (point)))))

;; (define-key scheme-mode-map (kbd "C-c C-c")
;; 		     'scheme-send-line)

;;========================================================================

;; (autoload 'scheme-smart-complete "scheme-complete" nil t)
;; (autoload 'scheme-complete-or-indent "scheme-complete" nil t)
;; (autoload 'scheme-get-current-symbol-info "scheme-complete" nil t)



;; (add-hook 'scheme-mode-hook
;;           (lambda ()
;;             (make-local-variable 'eldoc-documentation-function)
;;             (setq eldoc-documentation-function 'scheme-get-current-symbol-info)
;;             (eldoc-mode)))

;; (setq scheme-default-implementation "mzscheme")


(provide '50scheme)