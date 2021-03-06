;;; 50dired.el ---


(with-eval-after-load 'dired
  (require 'dired-quick-sort)
  (require 'dired+ nil t))

(setq dired-isearch-filenames 'dwim
      dired-recursive-copies 'always
      dired-recursive-deletes 'top
      ;; If non-nil, Dired tries to guess a default target directory.
      ;; This means: if there is a dired buffer displayed in the next window,
      ;; use its current subdir, instead of the current subdir of this dired buffer.
      dired-dwim-target t
      dired-guess-shell-gnutar "tar"
      dired-kept-versions 1)

;; Enable `a' in dired-mode, to open files/dirs in the same buffer.
(put 'dired-find-alternate-file 'disabled nil)

;;; darwin only
(when (eq system-type 'darwin)
  (let ((ls (executable-find "gls")))   ;; brew insall coreutils
    (cond (ls (setq dired-use-ls-dired t)
              (setq insert-directory-program ls))
          (t (require 'ls-lisp)
             (setq ls-lisp-use-insert-directory-program nil)))))

;;; omit mode
;; C-x M-o
(setq-default dired-omit-mode t)
(with-eval-after-load "dired-x"
  (setq dired-omit-extensions
        '(".svn/" "CVS/" ".o" "~" ".bin" ".bak" ".obj" ".map" ".ico"
          ".pif" ".lnk" ".a" ".ln" ".blg" ".bbl" ".dll" ".drv" ".vxd"
          ".386" ".elc" ".lof" ".glo" ".idx" ".lot" ".fmt" ".tfm"
          ".class" ".lib" ".mem" ".x86f" ".sparcf" ".fasl"
          ".ufsl" ".fsl" ".dxl" ".pfsl" ".dfsl" ".lo" ".la" ".gmo"
          ".mo" ".toc" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr"
          ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".pyc" ".pyo"
          ".idx" ".lof" ".lot" ".glo" ".blg" ".bbl" ".cps" ".fn"
          ".fns" ".ky" ".kys" ".pg" ".pgs" ".tp" ".tps" ".vr" ".vrs"
          ".pdb" ".ilk" ".lrc"))

  (setq dired-omit-size-limit 150000)
  (setq dired-guess-shell-alist-user    ; use ! to call guess command
        `((,(regexp-opt '(".gif" ".png" ".bmp" ".jpg" ".tif" ".jpeg"))
           '("qiv"                     ; feh, "xloadimage -onroot"
             ))
          ("\\.htm[l]?$" "firefox")
          ("\\.dvi$"    "xdvi")
          ("\\.rar$"    "unrar x")
          ("\\.pdf$"    ,(if (eq system-type 'gnu/linux)
                             "xpdf * &"
                           "open -a Preview"))
          ("\\.pdf.gz$" "zxpdf")
          ("\\.chm$"    "xchm")
          ("\\.djvu$"   "djview")
          ("\\.jar$"    "unzip")
          ("\\.tar.bz2$" "tar jxf")
          ;; (".doc" (xwl-dired-wvHtml))
          (,(regexp-opt '(".doc" ".ppt" ".xls" ".doc")) "soffice")
          ;; default
          ,@dired-guess-shell-alist-default
          ;; match any files
          (".*" `(,(format "tar zcf %s.tar.gz"
                           (file-name-nondirectory (dired-get-filename)))
                  ,(format "zip -r %s.jar"
                           (file-name-nondirectory (dired-get-filename)))
                  "qiv"))))
  (setq dired-omit-files
        (concat "^\\.?#\\|^\\.$\\|^\\.\\.$\\|^~\\|^\\.\\|^#.*#$\\|^nohup.out$\\|\\.jlc$"
                "\\|"
                (regexp-opt '("TAGS" "cscope.out")))))

;;; wdired
;; press `r' to modify the filename in the dired buffer, `C-c C-c' to commit
(autoload 'wdired-change-to-wdired-mode "wdired")
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;;;
;; Ask for confirm when opening some binary alike(.avi, .dvi, etc) files by accident.
(defadvice dired-find-file (around ask-confirm-open-binary-file)
  (let ((f (file-name-nondirectory (dired-filename-at-point))))
    (if (or (string-match
             (concat "\\.\\("
                     (regexp-opt '("dvi" "pdf" "avi" "mp3" "sub"))
                     "\\)$")
             f)
            ;; ELF bin file
            (string-match "ELF" (dired-show-file-type f)))
        (when (y-or-n-p (format "Really open `%s'? " f))
          ad-do-it)
        ad-do-it)))
(ad-activate 'dired-find-file)

;; diredp
(setq diredp-hide-details-initially-flag nil)
(setq diredp-hide-details-propagate-flag nil)

;;; Sorting
(setq dired-listing-switches "-alh")

;;; dired-quick-sort
(define-key dired-mode-map "s" 'hydra-dired-quick-sort/body)
;; Automatically use the sorting defined here to sort.
(add-hook 'dired-mode-hook 'dired-quick-sort)


(add-hook 'dired-mode-hook 'paloryemacs/dired-mode-hook-init)
(defun paloryemacs/dired-mode-hook-init ()
  (define-key dired-mode-map (kbd "^") 'diredp-up-directory-reuse-dir-buffer)
  (define-key dired-mode-map (kbd "W") 'paloryemacs/dired-w3m-find-file)
  (define-key dired-mode-map (kbd "/") 'dired-narrow)
  (define-key dired-mode-map [mouse-2] 'dired-mouse-find-file)
  (dired-omit-mode +1))

(with-eval-after-load "evil-evilified-state"
  (with-eval-after-load "dired"
    (evilified-state-evilify dired-mode dired-mode-map
      (kbd "%")    'nil
      (kbd "j")   'diredp-next-line
      (kbd "k")   'diredp-previous-line
      (kbd "^")   'diredp-up-directory-reuse-dir-buffer
      (kbd "l")   'diredp-find-file-reuse-dir-buffer
      (kbd "i")   'dired-omit-mode
      (kbd "I")   'dired-maybe-insert-subdir
      (kbd "M-r") 'dired-do-redisplay
      (kbd "r")   ' wdired-change-to-wdired-mode
      (kbd "gg")  'paloryemacs/dired-back-to-top
      (kbd "gr")  'revert-buffer
      (kbd "G")   'paloryemacs/dired-jump-to-bottom)))


(defun paloryemacs/dired-back-to-top ()
  "Move to the first file."
  (interactive)
  (beginning-of-buffer)
  (dired-next-line 2))

(defun paloryemacs/dired-jump-to-bottom ()
  "Move to last file."
  (interactive)
  (end-of-buffer)
  (dired-next-line -1))

(defun paloryemacs/dired-w3m-find-file ()
  (interactive)
  (let ((file (dired-get-filename)))
    (when (y-or-n-p (format "Open 'w3m' %s " (file-name-nondirectory file)))
      (w3m-find-file file))))


(defun paloryemacs/view-chm (file)
  (interactive
   (list (let ((file (dired-get-filename)))
           (or file
               (read-file-name "Open chm: ")))))
  (if (and file (string-match "\\.chm$" file))
      (let ((proc (get-process "archmage")))
        (with-current-buffer (get-buffer-create " *archmage*")
          (if (and proc (eq (process-status proc) 'run))
              (kill-process proc))
          (erase-buffer)
          (setq proc (start-process "archmage" (current-buffer)
                                    "archmage" "-p" "66616" file))
          (sit-for 0.5)
          (if (eq (process-status proc) 'run)
              (w3m "http://localhost:66616")
            (display-buffer (current-buffer)))))
    (message "Not chm file!")))


(defun dired-mouse-find-file (event)
  "In dired, visit the file or directory name you click on in this window."
  (interactive "e")
  (let (file)
    (save-excursion
      (set-buffer (window-buffer (posn-window (event-end event))))
      (save-excursion
        (goto-char (posn-point (event-end event)))
        (setq file (dired-get-filename))))
    (select-window (posn-window (event-end event)))
    (find-file (file-name-sans-versions file t))))

;;; emms
;; (define-key dired-mode-map (kbd "M-RET") 'emms-add-dired)

;;; gnus-dired-mode
;; C-c C-m C-a
;; "Send dired's marked files as an attachment (`gnus-dired-attach'). You
;; will be prompted for a message buffer."
;; (add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

;;; tumme - Dired's image browser
;; "tumme" means thumb in Swedish. You need ImageMagick installed for tumme to work.
;; M-x tummel-dired RET path/to/photo/dir RET
;; C-S-{n,p} browser thumbnail one by one
;; C-t .     thumbnail fo current file
;; C-t d     thumbnails of all of the marked file
;; TAB       exchange windows

;;; work with ImageMagic
;; thanks to http://ergoemacs.org/emacs/emacs_dired_convert_images.html
(define-key dired-mode-map (kbd "ESC ESC i s") 'paloryemacs/image-scale)
(defun paloryemacs/image-scale (file-list scale-args)
  "Create a scaled version of images of marked files in dired.
The new names have \"-s\" appended before the file name extension.
Requires ImageMagick shell tool."
  (interactive
   (list (dired-get-marked-files) (read-from-minibuffer "scale args: ")))
  (require 'dired)
  (mapc
   (lambda (f)
     (let ((new-file-name (concat (file-name-sans-extension f) "-s" (file-name-extension f t)))
           cmd-str)
       (while (file-exists-p new-file-name)
         (setq new-file-name (concat (file-name-sans-extension new-file-name) "-s" (file-name-extension new-file-name t))))

       ;; relative paths used to get around Windows/Cygwin path remapping problem
       (let ((cmd-str (concat "convert -scale "
                              scale-args
                              " "
                              (file-relative-name f)
                              " "
                              (file-relative-name new-file-name))))
         (shell-command cmd-str))))

   file-list))

;;; zip file/dir
(defun paloryemacs/2zip ()
  "Zip the current file/dir in `dired'.
If multiple files are marked, only zip the first one.
Require unix zip commandline tool."
  (interactive)
  (require 'dired)
  (let ((file-name (elt (dired-get-marked-files) 0)))
    (shell-command (format "zip -r '%s.zip' '%s'" (file-relative-name file-name) (file-relative-name file-name)))))

;;; open in external application
(define-key dired-mode-map (kbd "M-O") 'paloryemacs/open-in-external-application)
(defun paloryemacs/open-in-external-application ()
  "Open the current file or dired marked files in external app.
Works in Microsoft Windows, Mac OS X, Linux."
  (interactive)
  (let* ((file-list (if (eq major-mode 'dired-mode)
                        (dired-get-marked-files)
                      (list (buffer-file-name))))
         (do-or-not-p (if (<= (length file-list) 5)
                          t
                        (y-or-n-p "Open more than 5 files?") )))

    (when do-or-not-p
      (cond
       ((eq system-type 'windows-nt)
        (mapc (lambda (file-path)
                (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" file-path t t)))
              file-list))
       ((eq system-type 'darwin)
        (mapc (lambda (file-path)
                (let ((process-connection-type nil))
                  (start-process "" nil "open" file-path)))
              file-list))
       ((eq system-type 'gnu/linux)
        (mapc (lambda (file-path)
                (let ((process-connection-type nil))
                  (start-process "" nil "xdg-open" file-path)))
              file-list))
       (t (message "unsupported system!"))))))


;;; MailcapView
;; http://www.emacswiki.org/emacs/MailcapView
(autoload 'mailcap-view-find-file-hook "mailcap-view"
  "Hook function to view the file with `mailcap-view-file' if the file isn't a text file." t)
(autoload 'mailcap-view-file "mailcap-view"
  "Using the file extension, view the FILENAME with the appropriate
handler as determined by `mailcap-mime-info'.  If ASYNC is non-nil,
run the viewer in the background and store the output in the `*Async
Shell Command*' buffer.  Otherwise the viewer is run in the foreground
and blocks emacs.  The default for ASYNC is t." t)

;; FIXME: some of the file extension will not be treat as txt file,such as .js
(when (eq system-type 'gnu/linux)
  (add-hook 'find-file-hook 'mailcap-view-find-file-hook))



;;; tips
;; mark mutiple files in dired mode with m, press B to compile them to *.el.
;; dired-compare-directories
;; w     dired-copy-filename-as-kill. `C-u 0' prefix copy absolute file name
;; i     insert sub-directory
;; C-u i insert sub-directory with specify arguments of ls
;; C-u l change the arguments of ls of sub-directory

;; % u   Rename all marked (or next ARG) files to upper case.
;; % l   Rename all marked (or next ARG) files to lower case.
;; `F' `dired-do-find-marked-files' ; open several files at once?

(provide '50dired)

;; Local Variables:
;; coding: utf-8-unix
;; End:
