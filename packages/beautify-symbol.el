;; -*- coding: utf-8; mode: emacs-lisp; -*-

;; (require 'beautify-symbol)

(eval-when-compile
  (require 'cl))

;; see also
;; http://lists.nongnu.org/archive/html/geiser-users/2011-06/msg00004.html

(defvar beautify-symbol-modes '(emacs-lisp-mode
                                ilisp-mode
                                inferior-lisp-mode
                                lisp-interaction-mode
                                lisp-mode
                                sml-mode
                                inferior-sml-mode
                                latex-mode
                                c-mode
                                c++-mode
                                perl-mode
                                sh-mode
                                scheme-mode))

(defcustom beautify-symbol-patterns nil
  "A structure ((pattern symbol major-modes*)*)."
  ;; only one variable, so we won't bother creating a whole new group.
  :group 'font-lock
  :type '(repeat (list char string list)))

(setq beautify-symbol-patterns
      (let ((lispen '(emacs-lisp-mode
                      ilisp-mode
                      inferior-lisp-mode
                      lisp-interaction-mode
                      lisp-mode))
            (mlen    '(sml-mode
                       inferior-sml-mode))
            (texen   '(latex-mode))
            (c-like '(c-mode
                      c++-mode
                      perl-mode
                      sh-mode)))
        `((?\\ "\\textbackslash"     nil)
          (?| "\\textbar"            nil)
          (?¡ "!!"                   nil)
          (?¢ "cents?"               nil)
          (?£ "pounds?"              nil)
          (?¥ "yen"                  nil)
          (?© "&copy;"               nil)
          (?± "plus-minus"           nil)
          (?² "square"               nil)
          (?³ "cube"                 nil)
          (?· "dot-product"          nil)
          (?¼ "one-quarter"          nil)
          (?½ "one-half"             nil)
          (?¾ "three-quarters"       nil)
          (?× "*"                    (,@mlen))
          (?÷ "/"                    nil)
          (?☹ ":-("                  (erc-mode))
          (?☺ ":-)"                  (erc-mode))
          (?α "\\<alpha\\>"          (tuareg-mode haskell-mode))
          (?β "\\<beta\\>"           (tuareg-mode haskell-mode))
          (?γ "\\<gamma\\>"          (tuareg-mode haskell-mode))
          (?δ "\\<delta\\>"          (tuareg-mode haskell-mode))
          (?λ "\\<fn\\>"             (,@mlen))
          (?– "--"                   (texen))
          (?‖ "^ +\\(|\\)"           (tuareg-mode))
          (?‘ "`"                    nil)
          (?’ "'"                    nil)
          (?“ "``"                   nil)
          (?” "''"                   nil)
          (?‥ "[^.]\\(\\.\\.\\)[^.]" (perl-mode))
          (?… "[^.]\\(\\.\\.\\)[^.]" (haskell-mode))
          (?… "[^.]\\(\\.\\.\\.\\)[^.]" (perl-mode))
          (?‰ "/1000"                nil)
          (?‱ "/10000"               nil)

          ;; I think these should be ʹ and ʺ... :-/
          (?′ "[^']'[^']"            (tuareg-mode haskell-mode))
          (?″ "''"                   (tuareg-mode haskell-mode))
          (?‴ "'''"                  nil)
          (?‵ "`"                    nil)
          (?‵ "\\s \\('\\)[a-zA-Z]"          (inferior-sml-mode))
          (?‶ "\\s \\(''\\)[a-zA-Z]"         (inferior-sml-mode))
          (?‷ "\\s \\('''\\)[a-zA-Z]"        (inferior-sml-mode))
          (?′ "[a-zA-Z0-9_]\\('\\)\\s "      (,@mlen))
          (?″ "[a-zA-Z0-9_]\\(''\\)\\s "     (,@mlen))
          (?‴ "[a-zA-Z0-9_]\\('''\\)\\s "    (,@mlen))
          (?‶ "``"                   nil)
          (?‷ "```"                  nil)
          ;; I use 'standard-display-ascii' to change the ascii "<" and ">" display as UNICODE.
          ;; my monaco fonts display "< >" is so ugly.
          ;; (?‹ "<"                    (,@lispen ,@c-like text-mode muse-mode wordnet-mode))
          ;; (?› ">"                    (,@lispen ,@c-like text-mode muse-mode wordnet-mode))
          (?‼ "!!"                   (haskell-mode))
          (?‽ "!?"                   nil)
          (?← ":="                   (smalltalk-mode))
          (?← "<-"                   (tuareg-mode haskell-mode))
          (?↑ "\\^"                  (tuareg-mode))
          (?→ "->"                   (perl-mode tuareg-mode haskell-mode ,@mlen))
          (?⇒ "=>"                   (perl-mode ,@mlen))
          (?∀ "\\<List.for_all\\>"   (tuareg-mode))
          (?∀ "\\<\\(for\\)\\s +[^\\s ]+\\s +in\\>" (sh-mode))
          (?∀ "\\<forall\\>"         (perl-mode))
          (?∃ "\\<List.exists\\>"    (tuareg-mode))
          (?∃ "\\<thereexists\\>"    nil)
          (?∅ "\\[\\]"               (haskell-mode))
          (?∈ "\\<List.mem\\>"       (tuareg-mode))
          (?∈ "\\<for\\s +[^\\s ]+\\s +\\(in\\)\\>" (sh-mode))
          (?∏ "\\<product\\>"        nil)
          (?∑ "\\<sum\\>"            nil)
          (?∓ "minus-plus"           nil)
          (?√ "\\<sqrt\\>"           (tuareg-mode))
          (?∞ "\\<infinity\\>"       nil)
          (?∧ "\\<andalso\\>"        (,@mlen))
          (?∨ "\\<orelse\\>"         (,@mlen))
          (?≈ "~="                   (perl-mode))
          ;; (?≠ "/="                   (,@lispen haskell-mode))
          (?≠ "<>"                   (tuareg-mode ,@mlen))

          (?⁻ "~"                    (,@mlen)) ; unary negation
          (?≤ "<="                   t)
          (?≥ ">="                   t)
          ;; (?≪ "<<"                   (,@c-like shell-mode))
          ;; (?≫ ">>"                   (,@c-like shell-mode))

          ;;; c-like mode
          (?∅ "\\<NULL\\>"           (,@c-like))
          (?¬ "[( ]\\(!\\b\\)"       (,@c-like))                                 ; "\\<!\\>"
          (?√ " +\\(sqrt\\)("        (,@c-like))
          (?∧ "&&"                   (,@c-like tuareg-mode))
          (?∨ "||"                   (,@c-like tuareg-mode))
          (?≠ "\\!="                 (,@c-like tuareg-mode))
          (?≡ "=="                   (,@c-like tuareg-mode haskell-mode joy-mode))


          ;;; lispen & scheme
          ;; (?≡ "\\<eql\\>"            (,@lispen))
          ;; (?≣ "\\<equal\\>"          (,@lispen))
          ;; (?∖ "\\<set-difference\\>" (,@lispen))
          (?⋂ "(\\(intersection\\>\\)"   (,@lispen)) ; "\\<intersection\\>"
          (?⋃ "(\\(union\\>\\)"      (,@lispen))     ; "\\<union\\>"
          ;; (?∈ "\\<member\\>"         (,@lispen scheme-mode))
          (?∧ "(\\(and\\>\\)"        (,@lispen scheme-mode)) ; "\\<and\\>"
          (?∨ "(\\(or\\>\\)"         (,@lispen scheme-mode)) ; "\\<or\\>"
          (?∅ "\\<nil\\>"            (,@lispen tuareg-mode))
          (?∅ "'\\(()\\)"             (,@lispen scheme-mode))
          (?λ "(\\(lambda\\>\\)"     (,@lispen scheme-mode))
          (?λ "(c-\\(lambda\\>\\)"     (,@lispen scheme-mode)) ; gambit c-lambda
          (?¬ "(\\(not\\>\\)"        (,@lispen scheme-mode tuareg-mode haskell-mode ,@mlen)) ; "\\<not\\>"
          (?ƒ "(\\(defun\\>\\)"      (,@lispen))     ; "\\<defun\\>"
          (?Ψ "(\\(defvar\\>\\)"     (,@lispen))     ; "\\<defvar\\>"
          (?δ "[[(]\\(define\\)[^)]" (scheme-mode))
          (?δ "(c-\\(define\\)[^)]" (scheme-mode))   ; gambit c-define
          (?β "[[(]\\(let\\)\\(*\\|-\\)?" (,@lispen scheme-mode))
          (?ς "[[(]\\(set!\\)\\>" (scheme-mode))
          (?ρ  "[[(]\\(begin\\)\\>" (scheme-mode))
          (?ι "[[(]\\(if\\)\\>" (scheme-mode))
          (?⊤ "\\(#t\\)\\>" (scheme-mode))
          (?⊥ "\\(#f\\)\\>" (scheme-mode))


          ;; I make the assumption that you write "... *pointer", but
          ;; "...*..." or "... * ..." for multiplication.
          ;; This stuff isn't running so well, so I've switched it off.

          ;; (?⋆ "\\(?:[      (*]\\)\\(\\*\\)\\(?:[a-zA-Z0-9()*\n]\\)"                       (c-mode))
          ;; (?⋆ "\\(?:[a-zA-Z0-9()*]\\)\\(\\*\\)\\(?:[*)     ]\\)"                          (c-mode))
          ;; (?× "\\(?:[a-zA-Z0-9)]\\)\\(\\*\\)\\(?:[a-zA-Z0-9(]\\)"                         (c-mode))
          ;; (?× "\\(?:[a-zA-Z0-9)]\\)[       ]+\\(\\*\\)[    ]+\\(?:[a-zA-Z0-9(]\\)"        (c-mode))
          ;; (?÷ "\\(?:[a-zA-Z0-9)]\\)\\(\\/\\)\\(?:[a-zA-Z0-9(]\\)"                         (c-mode))
          ;; (?÷ "\\(?:[a-zA-Z0-9)]\\)[       ]+\\(\\/\\)[    ]+\\(?:[a-zA-Z0-9(]\\)"        (c-mode))

          ;; LaTeX text symbols. From http://www.ctan.org/tex-archive/info/symbols/comprehensive/symbols-a4.pdf
          ,@(map 'list (lambda (c p) (list c (format "\\(\\\\%s\\({}\\)?\\)" p) `(,@texen)))
                 "$%_}&#{†‡¶©§…£^~*\\|{}•©†‡$…—–¡><ªº¶·¿“”‘’®§£™_〈〉"
                 '("$" "%" "_" "}" "&" "#" "{" "dag" "ddag" "P" "copyright" "S" "dots" "pounds" "textasciicircum"
                   "textasciitilde" "textasteriskcentered" "textbackslash" "textbar" "textbraceleft" "textbraceright"
                   "textbullet" "textcopyright" "textdagger" "textdaggerdbl" "textdollar" "textellipsis" "textemdash"
                   "textendash" "textexclamdown" "textgreater" "textless" "textordfeminine" "textordmasculine"
                   "textparagraph" "textperiodcentered" "textquestiondown" "textquotedblleft" "textquotedblright"
                   "textquoteleft" "textquoteright" "textregistered" "textsection" "textsterling" "texttrademark"
                   "textunderscore" "textlangle" "textrangle"))

          ;; LaTeX math symbols.
          ,@(map 'list (lambda (c p) (list c (format "\\(\\\\%s\\(?:{}\\)?\\|\\$\\\\%s\\(?:{}\\)?\\$\\)" p p) `(,@texen)))
                 "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθϑικλμνξοπϖρςστυϒφχψω"
                 '("Alpha" "Beta" "Gamma" "Delta" "Epsilon" "Zeta" "Eta" "Theta"
                   "Iota" "Kappa" "Lambda" "Mu" "Nu" "Xi" "Omicron" "Pi" "Rho"
                   "Sigma" "Tau" "Upsilon" "Phi" "Chi" "Psi" "Omega" "alpha" "beta"
                   "gamma" "delta" "epsilon" "zeta" "eta" "theta" "thetasym" "iota"
                   "kappa" "lambda" "mu" "nu" "xi" "omicron" "pi" "piv" "rho"
                   "sigmaf" "sigma" "tau" "upsilon" "upsih" "phi" "chi" "psi"
                   "omega"))

          ;; This list is taken from the HTML4 spec.
          ,@(map 'list (lambda (c p) (list c (format "&%s;" p) '(html-mode)))
                 "¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿƒΑΒΓΔΕΖΗΘΙ
                  ΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθϑικλμνξοπϖρςστυϒφχψω•…′″‾⁄℘ℑℜ™ℵ←↑→↓↔↵⇐⇑⇑⇓⇔∀∂∃∅∇∈∉∋∏∑−∗√∝∞∠∧∨∩∪∫∴∼≅≈≠≡≤≥⊂⊃⊄⊆⊇⊕⊗
                  ⊥⋅⌈⌉⌊⌋〈〉◊♠♣♥♦\"&<>ŒœŠšŸ^~   ‌‍‎‏–—‘’‚“”„†‡‰‹›€"
                 '("iexcl" "cent" "pound" "curren" "yen" "brvbar" "sect" "uml"
                   "copy" "ordf" "laquo" "not" "shy" "reg" "macr" "deg" "plusmn"
                   "sup2" "sup3" "acute" "micro" "para" "middot" "cedil" "sup1"
                   "ordm" "raquo" "frac14" "frac12" "frac34" "iquest" "Agrave"
                   "Aacute" "Acirc" "Atilde" "Auml" "Aring" "AElig" "Ccedil"
                   "Egrave" "Eacute" "Ecirc" "Euml" "Igrave" "Iacute" "Icirc"
                   "Iuml" "ETH" "Ntilde" "Ograve" "Oacute" "Ocirc" "Otilde" "Ouml"
                   "times" "Oslash" "Ugrave" "Uacute" "Ucirc" "Uuml" "Yacute"
                   "THORN" "szlig" "agrave" "aacute" "acirc" "atilde" "auml"
                   "aring" "aelig" "ccedil" "egrave" "eacute" "ecirc" "euml"
                   "igrave" "iacute" "icirc" "iuml" "eth" "ntilde" "ograve"
                   "oacute" "ocirc" "otilde" "ouml" "divide" "oslash" "ugrave"
                   "uacute" "ucirc" "uuml" "yacute" "thorn" "yuml" "fnof" "Alpha"
                   "Beta" "Gamma" "Delta" "Epsilon" "Zeta" "Eta" "Theta" "Iota"
                   "Kappa" "Lambda" "Mu" "Nu" "Xi" "Omicron" "Pi" "Rho" "Sigma"
                   "Tau" "Upsilon" "Phi" "Chi" "Psi" "Omega" "alpha" "beta" "gamma"
                   "delta" "epsilon" "zeta" "eta" "theta" "thetasym" "iota" "kappa"
                   "lambda" "mu" "nu" "xi" "omicron" "pi" "piv" "rho" "sigmaf"
                   "sigma" "tau" "upsilon" "upsih" "phi" "chi" "psi" "omega" "bull"
                   "hellip" "prime" "Prime" "oline" "frasl" "weierp" "image" "real"
                   "trade" "alefsym" "larr" "uarr" "rarr" "darr" "harr" "crarr"
                   "lArr" "uArr" "rArr" "dArr" "hArr" "forall" "part"
                   "exist" "empty" "nabla" "isin" "notin" "ni" "prod" "sum" "minus"
                   "lowast" "radic" "prop" "infin" "ang" "and" "or" "cap" "cup"
                   "int" "there4" "sim" "cong" "asymp" "ne" "equiv" "le" "ge" "sub"
                   "sup" "nsub" "sube" "supe" "oplus" "otimes" "perp" "sdot"
                   "lceil" "rceil" "lfloor" "rfloor" "lang" "rang" "loz" "spades"
                   "clubs" "hearts" "diams" "quot" "amp" "lt" "gt" "OElig" "oelig"
                   "Scaron" "scaron" "Yuml" "circ" "tilde" "ensp" "emsp"
                   "thinsp" "zwnj" "zwj" "lrm" "rlm" "ndash" "mdash" "lsquo"
                   "rsquo" "sbquo" "ldquo" "rdquo" "bdquo" "dagger" "Dagger"
                   "permil" "lsaquo" "rsaquo" "euro")))))

(defun beautify-symbol-toggle (font-lock-add/remove-keywords)
  (dolist (x beautify-symbol-patterns)
    (if (or (eql t (third x))
            (find major-mode (third x)))
        (funcall font-lock-add/remove-keywords
                 nil
                 `((,(second x)
                     ;; if there is grouping, match the first group, else match the whole pattern.
                     (0
                      (prog1 nil
                        (compose-region (match-beginning ,(if (string-match "\\\\(.*\\\\)" (second x)) 1 0))
                                        (match-end       ,(if (string-match "\\\\(.*\\\\)" (second x)) 1 0))
                                        ,(first x))))))))))

(defun beautify-symbol-enable ()
  (beautify-symbol-toggle #'font-lock-add-keywords)
  (font-lock-fontify-buffer))

(defun beautify-symbol-disable ()
  (beautify-symbol-toggle #'font-lock-remove-keywords)
  (remove-text-properties (point-min) (point-max) '(composition nil)))

;;;###autoload
(define-globalized-minor-mode global-beautify-symbol-mode
    beautify-symbol-mode turn-on-beautify-symbol-mode)

(defun turn-on-beautify-symbol-mode ()
  (if (and (not (minibufferp (current-buffer)))
           (memq major-mode beautify-symbol-modes))
      (beautify-symbol-mode 1)))

(define-minor-mode beautify-symbol-mode
    "Minor mode for smooth scrolling."
  nil                     ; init value
  " λ"                    ; lighter
  nil                     ; keymap
  (if beautify-symbol-mode
      (beautify-symbol-enable)
      (beautify-symbol-disable)))

(provide 'beautify-symbol)
