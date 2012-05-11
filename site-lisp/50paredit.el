;;; 50paredit.el ---

;; Copyright (C) 2012  Shihpin Tseng

;; Author: Shihpin Tseng <deftsp@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;


(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)

;; additional paredit binding
(eval-after-load 'paredit
  '(progn
     ;; (define-key paredit-mode-map (kbd ";")   'self-insert-command)
     ;; (define-key paredit-mode-map (kbd "<delete>") 'paredit-forward-maybe-delete-region)
     ;; (define-key paredit-mode-map (kbd "DEL") 'paredit-backward-maybe-delete-region)
     ;; (define-key paredit-mode-map (kbd "RET") nil)
     ;; (define-key emacs-lisp-mode-map (kbd "RET") 'paredit-newline)
     ;; (define-key lisp-mode-shared-map (kbd "RET") 'paredit-newline)

     (define-key paredit-mode-map (kbd "H-m l")  'paredit-splice-sexp-killing-backward)
     (define-key paredit-mode-map (kbd "H-m h")  'paredit-splice-sexp-killing-forward)

     (define-key paredit-mode-map (kbd "H-l")   'paredit-forward-slurp-sexp)
     (define-key paredit-mode-map (kbd "H-M-l") 'paredit-forward-barf-sexp)

     (define-key paredit-mode-map (kbd "H-h")   'paredit-backward-slurp-sexp)
     (define-key paredit-mode-map (kbd "H-M-h") 'paredit-backward-barf-sexp)))



(dolist (hook '(emacs-lisp-mode-hook lisp-mode-hook inferior-lisp-mode-hook))
  (add-hook hook 'enable-paredit-mode))



(eval-after-load 'scheme
  '(progn
     (add-hook 'inferior-scheme-mode-hook 'enable-paredit-mode)
     (add-hook 'scheme-mode-hook 'enable-paredit-mode)

     ;;(define-key scheme-mode-map (kbd "C-M-l") 'paredit-recentre-on-sexp)
     (define-key scheme-mode-map (kbd "C-,") 'paredit-backward-slurp-sexp)
     (define-key scheme-mode-map (kbd "C-.") 'paredit-forward-slurp-sexp)
     (define-key scheme-mode-map (kbd "C-<") 'paredit-backward-barf-sexp)
     (define-key scheme-mode-map (kbd "C->") 'paredit-forward-barf-sexp)))

(eval-after-load 'slime
  '(progn
     (add-hook 'slime-repl-mode-hook 'enable-paredit-mode)))


(defun check-region-parens ()
  "Check if parentheses in the region are balanced. Signals a
scan-error if not."
  (interactive)
  (save-restriction
    (save-excursion
      (let ((deactivate-mark nil))
        (condition-case c
            (progn
              (narrow-to-region (region-beginning) (region-end))
              (goto-char (point-min))
              (while (/= 0 (- (point)
                              (forward-list))))
              t)
          (scan-error (signal 'scan-error '("Region parentheses not balanced"))))))))

(defun paredit-backward-maybe-delete-region ()
  (interactive)
  (if mark-active
      (progn
        (check-region-parens)
        (cua-delete-region))
    (paredit-backward-delete)))

(defun paredit-forward-maybe-delete-region ()
  (interactive)
  (if mark-active
      (progn
        (check-region-parens)
        (cua-delete-region))
    (paredit-forward-delete)))




(eval-after-load 'slime
  '(progn
     ;;(define-key slime-mode-map (kbd "C-<return>") 'paredit-newline)
     ;; (define-key slime-mode-map (kbd "[") 'insert-parentheses)
     ;;(define-key slime-mode-map (kbd "]") 'move-past-close-and-reindent)
     ;;(define-key slime-mode-map (kbd "(") (lambda () (interactive) (insert "[")))
     ;;(define-key slime-mode-map (kbd ")") (lambda () (interactive) (insert "]")))
     ;;(define-key slime-mode-map (kbd "(") 'paredit-open-parenthesis)
     ;;(define-key slime-mode-map (kbd ")") 'paredit-close-parenthesis)

     ;;(define-key slime-mode-map (kbd "C-M-l") 'paredit-recentre-on-sexp)
     (define-key slime-mode-map (kbd "C-,") 'paredit-backward-slurp-sexp)
     (define-key slime-mode-map (kbd "C-.") 'paredit-forward-slurp-sexp)
     (define-key slime-mode-map (kbd "C-<") 'paredit-backward-barf-sexp)
     (define-key slime-mode-map (kbd "C->") 'paredit-forward-barf-sexp)

     (global-set-key (kbd "C-c s") 'slime-selector)
     ;; (define-key slime-mode-map (kbd "C-c S") 'slime-selector)
     ;; (define-key slime-repl-mode-map (kbd "C-c S") 'slime-selector)
     ;; (define-key sldb-mode-map (kbd "C-c S") 'slime-selector)

     ;; Balanced comments
     (define-key slime-mode-map (kbd "C-c ;") 'slime-insert-balanced-comments)
     (define-key slime-mode-map (kbd "C-c M-;") 'slime-remove-balanced-comments)))



(provide '50paredit)
;;; 50paredit.el ends here