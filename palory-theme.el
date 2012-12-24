;;; palory-theme.el ---

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

;;; Commentary: palory theme, for programmer

;;; Code:

;;; base on https://github.com/bbatsov/zenburn-emacs/blob/master/zenburn-theme.el

(deftheme palory
  "The palory theme.")

(let ((palory-fg "#b6d3d6")
      (palory-fg-1 "#656555")
      (palory-bg-1 "#2b2b2b")
      (palory-bg-05 "#383838")
      (palory-bg "#282c30")
      (palory-bg+1 "#4f4f4f")
      (palory-bg+2 "#5f5f5f")
      (palory-bg+3 "#6f6f6f")
      (palory-red+1 "#dca3a3")
      (palory-red "#cc9393")
      (palory-red-1 "#bc8383")
      (palory-red-2 "#ac7373")
      (palory-red-3 "#9c6363")
      (palory-red-4 "#8c5353")
      (palory-orange "#dfaf8f")
      (palory-yellow "#f0dfaf")
      (palory-yellow-1 "#e0cf9f")
      (palory-yellow-2 "#d0bf8f")
      (palory-green-1 "#5f7f5f")
      (palory-green "#7f9f7f")
      (palory-green+1 "#8fb28f")
      (palory-green+2 "#9fc59f")
      (palory-green+3 "#afd8af")
      (palory-green+4 "#bfebbf")
      (palory-cyan "#93e0e3")
      (palory-blue+1 "#94bff3")
      (palory-blue "#8cd0d3")
      (palory-blue-1 "#7cb8bb")
      (palory-blue-2 "#6ca0a3")
      (palory-blue-3 "#5c888b")
      (palory-blue-4 "#4c7073")
      (palory-blue-5 "#366060")
      (palory-magenta "#dc8cc3"))

  (custom-theme-set-faces
   'palory

   `(default ((t (:background ,palory-bg :foreground ,palory-fg))))

   ;; highlight-symbol
   `(highlight-symbol-face ((t (:background "dodgerblue3" :foreground ,palory-fg))))

   ;; info
   '(info-xref ((t (:foreground "DeepSkyBlue2" :weight bold :underline nil))))
   '(info-xref-visited ((t (:inherit info-xref :weight normal))))
   '(info-header-xref ((t (:inherit info-xref))))
   '(info-menu-star ((t (:foreground "#dfaf8f" :weight bold))))
   '(info-menu-5 ((t (:foreground "#df998f"))))
   '(info-node ((t (:foreground "DodgerBlue1" :weight bold))))
   '(info-title-1 ((t (:foreground "green1"))))
   '(info-title-2 ((t (:foreground "green2"))))
   '(info-title-3 ((t (:foreground "green3"))))
   '(info-title-4 ((t (:foreground "DodgerBlue1"))))
   '(info-menu-header ((t (:foreground "LawnGreen"))))
   '(info-header-node ((t (:weight normal))))

   ;; mode-line
   '(mode-line-buffer-id ((t (:foreground "#90377d"))))
   '(mode-line ((t (:foreground "SteelBlue2" :background "#000000" :box nil)))) ; #222222
   '(mode-line-inactive ((t (:foreground "PaleTurquoise3" :background "#222222" :box nil)))) ; #111111
   '(mode-line-highlight ((t (:box nil))))

   ;; fringe
   `(fringe ((t (:foreground "green" :background ,palory-bg))))

   ;; tooltip
   '(tooltip ((t (:foreground "#111111" :background "#bcc8dd"))))

   ;; show-paren
   '(show-paren-match ((t (:foreground "SteelBlue3"))))
   '(show-paren-mismatch ((t (:foreground "white" :background "purple"))))

   ;; term
   '(term-color-blue ((t (:foreground "DeepSkyBlue4"))))


   ;; rainbow-delimiters
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#93e0e3"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#f0dfaf"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#94bff3"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#dca3a3"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "#8fb28f"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "#8cd0d3"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "#dfaf8f"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "#dc8cc3"))))
   '(rainbow-delimiters-depth-9-face ((t (:foreground "#d0bf8f"))))
   '(rainbow-delimiters-depth-10-face ((t (:foreground "#9fc59f"))))
   '(rainbow-delimiters-depth-11-face ((t (:foreground "#94bff3"))))
   '(rainbow-delimiters-depth-12-face ((t (:foreground "#8c5353")))))

  ;;; custom theme variables
  (custom-theme-set-variables
   'palory
   `(ansi-color-names-vector ['palory-bg ,palory-red ,palory-green ,palory-yellow
                                         ,palory-blue ,palory-magenta ,palory-cyan ,palory-fg])
   ;; fill-column-indicator
   `(fci-rule-color ,palory-bg-05)))




   ;;;###autoload
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path
                  (file-name-as-directory
                   (file-name-directory load-file-name))))



(provide-theme 'palory)

;; Local Variables:
;; no-byte-compile: t
;; indent-tabs-mode: nil
;; eval: (when (fboundp 'rainbow-mode) (rainbow-mode +1))
;; End:

;;; palory-theme.el ends here.
