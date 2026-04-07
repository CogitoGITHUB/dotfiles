#s(hash-table test equal data (:nodes #s(hash-table test equal data (#1="ec7beaff-8bb6-4af3-97a0-2cc162988d73" (:id #1# :title #2="The Case Table" :raw-value #2# :tags nil :properties nil :ref-to nil :file "~/.config/emacs/future work/manuals.org" :olp ("Elisp" "Strings and Characters" "The Case Table") :content "
You can customize case conversion by installing a special case table. A case table specifies the mapping between upper case and lower case letters. It affects both the case conversion functions for Lisp objects (see the previous section) and those that apply to text in the buffer (see Case Changes). Each buffer has a case table; there is also a standard case table which is used to initialize the case table of new buffers.

A case table is a char-table (see Char-Tables) whose subtype is case-table. This char-table maps each character into the corresponding lower case character. It has three extra slots, which hold related tables:

upcase
The upcase table maps each character into the corresponding upper case character.

canonicalize
The canonicalize table maps all of a set of case-related characters into a particular member of that set.

equivalences
The equivalences table maps each one of a set of case-related characters into the next character in that set.

In simple cases, all you need to specify is the mapping to lower-case; the three related tables will be calculated automatically from that one.

For some languages, upper and lower case letters are not in one-to-one correspondence. There may be two different lower case letters with the same upper case equivalent. In these cases, you need to specify the maps for both lower case and upper case.

The extra table canonicalize maps each character to a canonical equivalent; any two characters that are related by case-conversion have the same canonical equivalent character. For example, since ‘a’ and ‘A’ are related by case-conversion, they should have the same canonical equivalent character (which should be either ‘a’ for both of them, or ‘A’ for both of them).

The extra table equivalences is a map that cyclically permutes each equivalence class (of characters with the same canonical equivalent). (For ordinary ASCII, this would map ‘a’ into ‘A’ and ‘A’ into ‘a’, and likewise for each set of equivalent characters.)

When constructing a case table, you can provide nil for canonicalize; then Emacs fills in this slot from the lower case and upper case mappings. You can also provide nil for equivalences; then Emacs fills in this slot from canonicalize. In a case table that is actually in use, those components are non-nil. Do not try to specify equivalences without also specifying canonicalize.

Here are the functions for working with case tables:

Function: case-table-p object ¶
This predicate returns non-nil if object is a valid case table.

Function: set-standard-case-table table ¶
This function makes table the standard case table, so that it will be used in any buffers created subsequently.

Function: standard-case-table ¶
This returns the standard case table.

Function: current-case-table ¶
This function returns the current buffer’s case table.

Function: set-case-table table ¶
This sets the current buffer’s case table to table.

Macro: with-case-table table body… ¶
The with-case-table macro saves the current case table, makes table the current case table, evaluates the body forms, and finally restores the case table. The return value is the value of the last form in body. The case table is restored even in case of an abnormal exit via throw or error (see Nonlocal Exits).

Some language environments modify the case conversions of ASCII characters; for example, in the Turkish language environment, the ASCII capital I is downcased into a Turkish dotless i (‘ı’). This can interfere with code that requires ordinary ASCII case conversion, such as implementations of ASCII-based network protocols. In that case, use the with-case-table macro with the variable ascii-case-table, which stores the unmodified case table for the ASCII character set.

Variable: ascii-case-table ¶
The case table for the ASCII character set. This should not be modified by any language environment settings.

The following three functions are convenient subroutines for packages that define non-ASCII character sets. They modify the specified case table case-table; they also modify the standard syntax table. See Syntax Tables. Normally you would use these functions to change the standard case table.

Function: set-case-syntax-pair uc lc case-table ¶
This function specifies a pair of corresponding letters, one upper case and one lower case.

Function: set-case-syntax-delims l r case-table ¶
This function makes characters l and r a matching pair of case-invariant delimiters.

Function: set-case-syntax char syntax case-table ¶
This function makes char case-invariant, with syntax syntax.

Command: describe-buffer-case-table ¶
This command displays a description of the contents of the current buffer’s case table.




" :level 3 :todo nil :priority nil :scheduled nil :deadline nil :position 4300260 :pos 4300260 :type :node :hash "1040ebd47c32d7531be40cb59e4868132c50779e" :orphaned-at nil :created-at (27093 23071 464601 249000) :modified-at (27093 23071 464602 468000)) #3="d15d6141-fca2-4919-86c0-2c901d009117" (:title "test-package" :type :node :id #3# :created-at (27093 23555 405134 538000) :modified-at (27093 23555 405135 600000)) #4="41c140d1-ff22-48ca-ad9e-bb99cbfe75c5" (:title "Package: org-supertag" :type :node :package "org-supertag" :file "org-supertag.org" :category #13="???" :id #4# :created-at (27093 23571 126030 461000) :modified-at (27093 23571 126031 619000)) #5="4ddbabec-a591-411c-9a9c-0e1ef6736041" (:title "Package: emacs-org-mcp" :type :node :package "emacs-org-mcp" :file "org-mcp.org" :category "ai" :id #5# :created-at (27093 23571 145201 397000) :modified-at (27093 23571 145202 464000)) #6="ae150f2b-84cc-4bab-864b-8f3b451a658a" (:title "Package: opencode" :type :node :package "opencode" :file "opencode-el.org" :category "ai" :id #6# :created-at (27093 23571 159038 989000) :modified-at (27093 23571 159039 946000)) #7="caf7105b-92d5-45c0-af90-23282a41dd97" (:title "Package: multiple-cursors" :type :node :package "multiple-cursors" :file "multiple-cursors.org" :category "editing" :id #7# :created-at (27093 23571 172543 245000) :modified-at (27093 23571 172543 920000)) #8="12727ecb-a97f-48f7-ba35-3e1b32c90286" (:title "Package: modus-themes" :type :node :package "modus-themes" :file "modus-theme.org" :category "ui" :id #8# :created-at (27093 23571 185622 99000) :modified-at (27093 23571 185622 971000)) #9="2913ff83-4243-4f1b-af5d-6bf9357582df" (:title "Package: mcp" :type :node :package "mcp" :file "mcp.org" :category "ai" :id #9# :created-at (27093 23571 198247 36000) :modified-at (27093 23571 198248 15000)) #10="c79a2468-e527-4a52-91bd-25eed0154b64" (:title "Package: leaf" :type :node :package "leaf" :file "leaf.org" :category "framework" :id #10# :created-at (27093 23571 210765 883000) :modified-at (27093 23571 210766 605000)) #11="da98a07c-e2a4-4341-b075-8be9f015adc2" (:title "Package: god-mode" :type :node :package "god-mode" :file "god-mode.org" :category "editing" :id #11# :created-at (27093 23571 225386 536000) :modified-at (27093 23571 225387 227000)) #12="b07d3c56-1131-42d4-b7a5-89f974484340" (:title "Package: geiser" :type :node :package "geiser" :file "geiser.org" :category "development" :id #12# :created-at (27093 23571 238379 323000) :modified-at (27093 23571 238380 202000)) #14="67724063-886b-4ce5-be5c-d117bc877404" (:title "Package: dashboard" :type :node :package "dashboard" :file "dashboard.org" :category #13# :id #14# :created-at (27093 23571 250750 283000) :modified-at (27093 23571 250751 40000)) #15="1de1d7ea-8dbc-437b-a406-c46c54212d51" (:title "Package: avy" :type :node :package "avy" :file "avy.org" :category "navigation" :id #15# :created-at (27093 23571 263675 883000) :modified-at (27093 23571 263676 583000)) #16="816690ad-84f0-4e85-859e-b7a76f87cfc7" (:title "Package: org-supertag" :type :node :package "org-supertag" :file "org-supertag.org" :category "system" :id #16# :created-at (27093 23663 594560 133000) :modified-at (27093 23663 594560 955000)) #17="79ebc05a-08fb-4b35-96de-e7960196d195" (:title "Package: emacs-org-mcp" :type :node :package "emacs-org-mcp" :file "org-mcp.org" :category "ai" :id #17# :created-at (27093 23663 607433 309000) :modified-at (27093 23663 607434 4000)) #18="dfc9c6cc-6c5d-469e-b0c8-686ba96fa39e" (:title "Package: opencode" :type :node :package "opencode" :file "opencode-el.org" :category "ai" :id #18# :created-at (27093 23663 620419 514000) :modified-at (27093 23663 620420 381000)) #19="b0c6fa67-720d-4384-ad91-82778de85f33" (:title "Package: multiple-cursors" :type :node :package "multiple-cursors" :file "multiple-cursors.org" :category "editing" :id #19# :created-at (27093 23663 633070 344000) :modified-at (27093 23663 633071 77000)) #20="9d38b1fc-5a94-458b-924f-2a93dee8ad89" (:title "Package: modus-themes" :type :node :package "modus-themes" :file "modus-theme.org" :category "ui" :id #20# :created-at (27093 23663 647350 137000) :modified-at (27093 23663 647350 870000)) #21="8219558d-a19d-4f12-8ce0-0e1fb82896bc" (:title "Package: mcp" :type :node :package "mcp" :file "mcp.org" :category "ai" :id #21# :created-at (27093 23663 660113 932000) :modified-at (27093 23663 660114 718000)) #22="8f443acb-155c-469c-a097-84001a089924" (:title "Package: leaf" :type :node :package "leaf" :file "leaf.org" :category "framework" :id #22# :created-at (27093 23663 672706 196000) :modified-at (27093 23663 672706 892000)) #23="32025729-92f0-46db-af38-63e2ed657204" (:title "Package: god-mode" :type :node :package "god-mode" :file "god-mode.org" :category "editing" :id #23# :created-at (27093 23663 685681 318000) :modified-at (27093 23663 685682 109000)) #24="02b2c897-7f6e-4d21-8aaf-acc0a5617556" (:title "Package: geiser" :type :node :package "geiser" :file "geiser.org" :category "development" :id #24# :created-at (27093 23663 698467 239000) :modified-at (27093 23663 698467 922000)) #25="89663396-d527-4873-b4a4-18c48b09f058" (:title "Package: dashboard" :type :node :package "dashboard" :file "dashboard.org" :category "ui" :id #25# :created-at (27093 23663 710981 457000) :modified-at (27093 23663 710982 138000)) #26="167f2f18-d442-4436-bb82-b700421461ea" (:title "Package: avy" :type :node :package "avy" :file "avy.org" :category "navigation" :id #26# :created-at (27093 23663 723832 924000) :modified-at (27093 23663 723833 609000)))) :tags #s(hash-table test equal) :relations #s(hash-table test equal) :embeds #s(hash-table test equal) :fields #s(hash-table test equal) :field-definitions #s(hash-table test equal) :tag-field-associations #s(hash-table test equal) :field-values #s(hash-table test equal) :boards #s(hash-table test equal) :meta #s(hash-table test equal) :type #s(hash-table test equal) :all #s(hash-table test equal)))