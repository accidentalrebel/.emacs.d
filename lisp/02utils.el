;;; 02utils.el ---

;; Copyright (C) 2013  Shihpin Tseng

;; Author: Shihpin Tseng <deftsp@gmail.com>


;;; neat stuffs
(require 'key-chord nil t)

(defun paloryemacs-buffer/warning (msg &rest args)
  "Display MSG as a warning message but in buffer `*Messages*'.
The message is always displayed. "
  (message "(Paloryemacs) Warning: %s" (apply 'format msg args)))


;; http://oremacs.com/2015/03/05/testing-init-sanity/
(defun paloryemacs/test-emacs ()
  "Testing your .emacs sanity.
If there were no start up errors, it will echo \"All is well\",
otherwise, it will pop to a *startup error* buffer with the error description."
  (interactive)
  (require 'async)
  (async-start
   (lambda ()
     (let ((current-emacs (concat invocation-directory invocation-name)))
       (shell-command-to-string
        (concat current-emacs " --batch --eval \"
(condition-case e
    (progn
      (load \\\"~/.emacs.d/init.el\\\")
      (message \\\"-OK-\\\"))
  (error
   (message \\\"ERROR!\\\")
   (signal (car e) (cdr e))))\""))))
   `(lambda (output)
      (if (string-match "-OK-" output)
          (when ,(called-interactively-p 'any)
            (message "All is well"))
        (switch-to-buffer-other-window "*startup error*")
        (delete-region (point-min) (point-max))
        (insert output)
        (search-backward "ERROR!")))))

(defmacro aif (&rest forms)
  "Create an anonymous interactive function.
    Mainly for use when binding a key to a non-interactive function."
  `(lambda () (interactive) ,@forms))

(if (fboundp 'with-eval-after-load)
    (defmacro paloryemacs/after (feature &rest body)
      "After FEATURE is loaded, evaluate BODY."
      (declare (indent defun))
      `(with-eval-after-load ,feature ,@body))
  (defmacro paloryemacs/after (feature &rest body)
    "After FEATURE is loaded, evaluate BODY."
    (declare (indent defun))
    `(eval-after-load ,feature
       '(progn ,@body))))


(defun paloryemacs/future-time-string (delay)
  (format-time-string "%H:%M:%S"
                      (seconds-to-time (+ (time-to-seconds (current-time))
                                          delay))))



(defun paloryemacs/apostrophe-key-chord ()
  (interactive)
  (let* ((regionp (region-active-p))
         (end (if regionp
                  (prog1 (region-end)
                    (goto-char (region-beginning)))
                0)))
    (insert "`")
    (save-excursion
      (if regionp
          (goto-char (+ end 1)))
      (insert "'"))))

(defun paloryemacs/underline-with-char (char)
  (interactive (list (read-from-minibuffer "Char: ")))
  (when (= 0 (length char))
    (error "Need a character"))
  (setq char (aref char 0))             ; Ignore everything but the first char.
  (save-excursion
    (goto-char (point-at-eol))
    (insert "\n"
            (make-string (- (point-at-eol)
                            (point-at-bol))
                         char))))


;;; face :: useful macro ----------------------------------------------------
(defmacro set-face-color (&rest list)
  `(set-face-color-1 (quote ,list)))

(defun set-face-color-1 (list)
  (let (face f-color b-color)
    (while list
      (setq face (pop list)
            f-color (pop list)
            b-color (pop list))
      ;; (make-face face)
      (set-face-attribute face nil
                          :background b-color
                          :box nil
                          :foreground f-color
                          :inherit nil
                          :slant 'normal
                          :strike-through nil
                          :underline nil
                          ;; :height 1.0
                          :weight 'normal))))

(defun get-face-hex (red green blue)
  "Return string hex of color specified by RED GREEN BLUE."
  (format "#%02x%02x%02x" (lsh red -8) (lsh green -8) (lsh blue -8)))

(defun get-face-step (list number color)
  "Return NUMBER of gradient for LIST of index COLOR."
  (let ((start (nth color (car list)))
        (end (nth color (cadr list))))
    (if (= end start)
        (make-list number start)
      (number-sequence start end (/ (- end start) (- number 1))))))

(defun get-face-gradient (face-prefix number color-start color-end)
  "Create NUMBER of FACE-PREFIX from COLOR-START to COLOR-END."
  (let* ((list (list (color-values color-start) (color-values color-end)))
         (red (get-face-step list number 0))
         (green (get-face-step list number 1))
         (blue (get-face-step list number 2))
         (num 0))
    (while (< num number)
      (let ((face (make-face
                   (intern
                    (concat face-prefix (number-to-string (1+ num)))))))
        (set-face-attribute face
                            nil :foreground
                            (get-face-hex (nth num red)
                                          (nth num green)
                                          (nth num blue))))
      (set 'num (1+ num)))))


;; require-soft  (http://www.emacswiki.org/cgi-bin/wiki/LocateLibrary)
;; this is useful when this .emacs is used in an env where not all of the
;; other stuff is available
(defmacro require-soft (feature &optional file)
  "*Try to require FEATURE, but don't signal an error if `require' fails."
  `(require ,feature ,file 'noerror))

(defmacro when-available (func foo)
  "*Do something if FUNCTION is available."
  `(when (fboundp ,func) ,foo))

;;;;;;;;;;;;

(defun mt-to-omr (start end)
  "Change muse tag to org mark rule"
  (interactive "r")
  (save-excursion
    (format-replace-strings '(("<example>" . "#+BEGIN_EXAMPLE")
                              ("</example>" . " #+END_EXAMPLE ")
                              ("<code>" . " #+BEGIN_EXAMPLE ")
                              ("</code>" . " #+END_EXAMPLE ")
                              ("<src lang=\"shell-script\">" . "#+BEGIN_SRC shell-script")
                              ("<src lang=\"emacs-lisp\"" . "#+BEGIN_SRC emacs-lisp")
                              ("<src lang=\"conf\"" . "#+BEGIN_SRC conf")
                              ("<src lang=\"lisp\"" . "#+BEGIN_SRC lisp")
                              ("<src lang=\"c\"" . "#+BEGIN_SRC c")
                              ("<src lang=\"c++\"" . "#+BEGIN_SRC c++")
                              ("</src>" . "#+END_SRC"))
                            nil
                            start
                            end)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_EXAMPLE.*$/#+BEGIN_EXAMPLE/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+END_EXAMPLE.*$/#+END_EXAMPLE/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_SRC\ .*shell.*$/#+BEGIN_SRC shell-script/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_SRC\ .*emacs.*$/#+BEGIN_SRC emacs-lisp/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_SRC\ .*lisp.*$/#+BEGIN_SRC lisp/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_SRC\ .*c$/#+BEGIN_SRC c/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+BEGIN_SRC\ .*conf.*$/#+BEGIN_SRC conf/g'" nil t)
    (shell-command-on-region start end "sed 's/^.*#\+END_SRC.*$/#+END_SRC/g'" nil t)))

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; full-screen mode
;; based on http://www.emacswiki.org/cgi-bin/wiki/WriteRoom
;; toggle full screen with F11; require 'wmctrl'
;; http://stevenpoole.net/blog/goodbye-cruel-word/

;; (when (executable-find "wmctrl") ; apt-get install wmctrl
;;   (defun full-screen-toggle ()
;;     (interactive)
;;     (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))
;;   (global-set-key (kbd "<f11>")  'full-screen-toggle))

;; (global-set-key [f11]
;;       (lambda ()
;;         (interactive)
;;         (x-send-client-message
;;          nil 0 nil "_NET_WM_STATE" 32
;;          '(2 "_NET_WM_STATE_FULLSCREEN" 0))))

;; maximal
;; (defun my-maximized-horz ()
;;   (interactive)
;;   (x-send-client-message
;;    nil 0 nil "_NET_WM_STATE" 32
;;    '(1 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))
;; (defun my-maximized-vert ()
;;   (interactive)
;;   (x-send-client-message
;;    nil 0 nil "_NET_WM_STATE" 32
;;    '(1 "_NET_WM_STATE_MAXIMIZED_VERT" 0)))
;; (defun my-maximized ()
;;   (interactive)
;;   (x-send-client-message
;;    nil 0 nil "_NET_WM_STATE" 32
;;    '(1 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
;;   (x-send-client-message
;;    nil 0 nil "_NET_WM_STATE" 32
;;    '(1 "_NET_WM_STATE_MAXIMIZED_VERT" 0)))


(defun DE-add-line-spacing (&optional spacing start end force)
  "Add line SPACING to each newline of region START END.
If SPACING is omitted, remove line-height property of all newlines.
If region START END is not specified, use whole current buffer.
If FORCE is non-nil, overwrite any existing line-height properties."
  (interactive)
  (let ((height (progn (redisplay) (car (window-line-height)))))
    (unless (and start end)
      (setq start (point-min)
            end (point-max)))
    (save-excursion
      (goto-char start)
      (while (search-forward "\n" end t)
        (if spacing
            (when (or force
                      (null (get-text-property (1- (point)) 'line-height)))
              (replace-match (propertize "\n" 'line-height (+ height spacing))))
          (remove-text-properties (1- (point)) (point) '(line-height)))))))

;;; copy
(defun copy-line (&optional arg)
  "Save current line into Kill-Ring without mark the line"
  (interactive "P")
  (let ((beg (line-beginning-position))
        (end (line-end-position arg)))
    (copy-region-as-kill beg end)))


(defun copy-word (&optional arg)
  "Copy words at point"
  (interactive "P")
  (let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-word 1)) (point)))
        (end (progn (forward-word arg) (point))))
    (copy-region-as-kill beg end)))

(defun copy-paragraph (&optional arg)
  "Copy paragraphes at point"
  (interactive "P")
  (let ((beg (progn (backward-paragraph 1) (point)))
        (end (progn (forward-paragraph arg) (point))))
    (copy-region-as-kill beg end)))

;;; Towards smoother scrolling in Emacs
;; http://www.randomsample.de/dru5/node/25
(defun DE-visual-scroll-up (&optional arg)
  (interactive)
  (if (pos-visible-in-window-p (point-max))
      (message "End of buffer")
      (unless arg
        (setq arg 1))
      (let ((cur (point))
            pos visible)
        (setq pos
              (save-excursion
                (while (and (search-forward "\n" nil t)
                          (= (length (pos-visible-in-window-p
                                      (point) nil t)) 2)))
                (1- (point))))
        (setq visible
              (pos-visible-in-window-p pos nil t))
        ;; if point is fully visible, we can go there
        (when (and (= (length visible) 2)
                 (not (= pos cur)))
          (goto-char pos))
        ;; if point is partly visible, we only go there if we absolutely
        ;; have to (point is already at the top)
        (when (and (= pos cur)
                 (null (pos-visible-in-window-p (1- (point)))))
          (forward-line 1))
        (set-window-vscroll nil (+ (window-vscroll) arg)))))

(defun DE-visual-scroll-down (&optional arg)
  (interactive)
  (if (pos-visible-in-window-p (point-min))
      (message "Beginning of buffer")
      (unless arg
        (setq arg 1))
      (let ((cur (point))
            pos visible)
        (setq pos
              (save-excursion
                (while (and (search-backward "\n" nil t)
                          (= (length (pos-visible-in-window-p (point) nil t)) 2)))
                (+ 1 (point))))
        (setq visible
              (pos-visible-in-window-p pos nil t))
        (when (and (= (length visible) 2)
                 (not (= pos cur)))
          (goto-char pos))
        (when (and (= pos cur)
                 (null (pos-visible-in-window-p
                        (save-excursion (forward-line 1) (point)))))
          (goto-char (1- (point))))
        (when (zerop (window-vscroll))
          (message "vscroll is 0. Reverting to scroll-down.")
          (scroll-down arg))
        (set-window-vscroll nil (- (window-vscroll) arg)))))


(defun fcitx-mb-eim ()
  (interactive)
  (while (search-forward-regexp "^\\([a-z;',./]*\\)\\ " nil t)
    (let ((str (match-string 1)))
      (replace-match (concatenate 'string "(\"" str "\" "))))

  ;; (goto-char (point-min))
  ;; (while (search-forward-regexp "^\\(.*\\)\\ \\(.*\\)\\ \\(.*\\)$" nil t)
  ;;   (let ((str1 (match-string 1))
  ;;         (str2 (match-string 2))
  ;;         (str3 (match-string 3)))
  ;;     (replace-match (concatenate 'string "(\"" str1 "\" " "\"" str2 "\" " "\"" str3 "\")"))))

  (goto-char (point-min))
  (while (search-forward-regexp "\\ \\(\\cc*\\)" nil t)
    (let ((str (match-string 1)))
      (replace-match (concatenate 'string " \"" str "\""))))

  (goto-char (point-min))
  (while (search-forward-regexp "\\(.$\\)" nil t)
    (let ((str (match-string 1)))
      (replace-match (concatenate 'string str ")")))))




(defun pretty-return-type-str (str &optional add-space)
  (let ((substr-1 (substring str -1))
        (substr-2 (substring str -2 -1)))
    (if (string= substr-1 "*")
        (concat (if (not (string= substr-2 " ")) (concat (substring str 0 -1) " *") str)
                (if add-space " " ""))
      (concat str " "))))

(defun objc-call-to-cpp-without-nesting (from to)
  (interactive "r")
  (let* ((method-call-part-name " *: *")
         (method-call-formal-name "\\([^]:]*\\)")
         (method-call-suffix " *\\] *;")
         (method-call-base "\\[ *\\([^ ]*\\) *\\([^ :]*\\)")
         (method-call-no-arg (concat method-call-base method-call-suffix))
         (method-call-1-arg (concat method-call-base
                                    method-call-part-name
                                    method-call-formal-name
                                    method-call-suffix))
         (method-call-2-arg (concat method-call-base
                                    method-call-part-name
                                    method-call-formal-name
                                    method-call-part-name
                                    method-call-formal-name
                                    method-call-suffix)))

    (goto-char from)
    (while (search-forward-regexp method-call-no-arg to t)
      (replace-match (concat (match-string 1)
                             "->"
                             (match-string 2)
                             "();")))

    (goto-char from)
    (while (search-forward-regexp method-call-1-arg to t)
      (replace-match (concat (match-string 1)
                             "->"
                             (match-string 2)
                             "("
                             (match-string 3)
                             ")")))



    (goto-char from)
    (while (search-forward-regexp method-call-2-arg to t)
     (replace-match (concat (match-string 1)
                            "->"
                            (match-string 2)
                            "("
                            (match-string 3)
                            ", "
                            (match-string 4)
                            ")"

                            )))


    ))


;;; TODO: recursive
(defun handle-square-bracket (from to expr)
  (let ((open-bracket (search-forward "[" nil t))
        (next-bracket (search-forward-regexp "\\[\\|\\]" nil t))
        (expr (if expr expr "")))

    ;; (concat expr )

      (if (string= next-bracket "[")
          (handle-square-bracket (match-beginning 1) to)

        )


    ))

;;; special region to eval
(defun objc-to-cpp (from to)
  "convert objc code to cpp code."
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))

  (save-excursion
    (let* ((class-name-str (file-name-sans-extension (buffer-name)))
           (method-prefix-regexp "^ *[-\\+] *( *")
           (type-regexp "\\([^ ]* *\\*?\\)")
           (method-name-regexp "\\([^ :;\n]*\\)")
           (method-name-base-regexp (concat
                                     method-prefix-regexp
                                     type-regexp
                                     " *) *"
                                     method-name-regexp))
           (method-declare-suffix-regexp " *;")
           (method-define-suffix-regexp " *\\([\{\n]\\)")
           (method-argument-name-regexp "[^ :;\n]*")
           (method-formal-argument-name-regexp "\\([^ :\n]*\\)")
           (method-name-with-1-arg-base (concat method-name-base-regexp
                                                " *: *( *"
                                                type-regexp
                                                " *) *"
                                                method-formal-argument-name-regexp
                                                )))

      (dolist (convertor
               '((while (search-forward-regexp "\\(@ *\\)\".*\"" to t)
                   (replace-match "" nil t nil 1))

                 (while (search-forward-regexp "\\(@ *\\)\".*\"" to t)
                   (replace-match "" nil t nil 1))

                 (while (search-forward-regexp "\\bYES\\b" to t)
                   (replace-match "true" t t nil))

                 (while (search-forward-regexp "\\bNO\\b" to t)
                   (replace-match "false" t t nil))

                 (while (search-forward-regexp "\\bNO\\b" to t)
                   (replace-match "false" t t nil))


                 (while (search-forward-regexp "#\\(import\\)\\b " to t)
                   (replace-match "include" nil t nil 1))

                 ;; NSXxx / CGXxx
                 (while (search-forward-regexp "\\b\\(NS\\|CG\\)[A-Z]" to t)
                   (replace-match "CC" nil t nil 1))

                 ;; -/+(xx) xxx;
                 (while (search-forward-regexp (concat method-name-base-regexp method-declare-suffix-regexp) to t)
                   (let ((return-type-str (pretty-return-type-str (match-string 1)))
                         (method-name-str (match-string 2)))
                     (replace-match (concat return-type-str method-name-str "();"))))

                 ;; -/+(xx) xxx {
                 ;; auto add xxx:: by filename
                 (while (search-forward-regexp (concat method-name-base-regexp method-define-suffix-regexp) to t)
                   (let ((return-type-str (pretty-return-type-str (match-string 1)))
                         (method-name-str (match-string 2))
                         (same-lines-p (string= (match-string 3) "{")))
                     (replace-match (concat return-type-str class-name-str "::" method-name-str
                                            (if same-lines-p "\n{" "\n")))))

                 ;; -(xxx) xxx: (xxx)xxx
                 (while (search-forward-regexp (concat method-name-with-1-arg-base method-declare-suffix-regexp) to t)
                   (let ((return-type-str (pretty-return-type-str (match-string 1)))
                         (method-name-str (match-string 2))
                         (argument-1-type-str (pretty-return-type-str (match-string 3)))
                         (argument-1-name-str (match-string 4)))
                     (replace-match (concat return-type-str
                                            method-name-str
                                            "("
                                            argument-1-type-str
                                            argument-1-name-str
                                            ");"))))

                 (while (search-forward-regexp (concat method-name-with-1-arg-base method-define-suffix-regexp) to t)
                   (let ((return-type-str (pretty-return-type-str (match-string 1)))
                         (method-name-str (match-string 2))
                         (argument-1-type-str (pretty-return-type-str (match-string 3)))
                         (argument-1-name-str (match-string 4))
                         (same-lines-p (string= (match-string 5) "{")))
                     (replace-match (concat return-type-str
                                            class-name-str "::"
                                            method-name-str
                                            "("
                                            argument-1-type-str
                                            argument-1-name-str
                                            ")"
                                            (if same-lines-p "\n{" "\n")))))







                 ))
        (goto-char from)
        (eval convertor)))))

(defvar paloryemacs/dircolors-string
  (let ((dircolors-bin
         (or (executable-find "dircolors") (executable-find "gdircolors"))))
    (when (executable-find dircolors-bin)
      (replace-regexp-in-string
       ":$" "" (cadr
                (split-string
                 (shell-command-to-string
                  (concat "TERM=xterm-color-256color " dircolors-bin))
                 "'"))))))


(provide '02utils)
;;; 02utils.el ends here
