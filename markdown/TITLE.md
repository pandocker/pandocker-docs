\newpage

\newpage

\toc

# はじめに {-}

このドキュメントは、Pandocベースのドキュメントコンパイラ*Pandocker*をできるだけ細かく・詳しく・網羅的に
解説する本です。Pandocの国内"エンジニア"[^strict-engineer-definition] 界隈での知名度が上がってきたことで、
Pandoc系ドキュメントコンパイラ[^not-a-lie]とか言っておけば食いつきがいいかもなどという妥協と、
シリーズ化して差分しか掲載せずにいると売れ行きが良くないため、周辺情報をまとめた「総集編２」を出します。

[^strict-engineer-definition]: ちなみに筆者は「エンジニア」の[*定義*]{.underline}に敏感です。\
ITエンジニアを指してエンジニアと呼称する場面に遭遇すると「は？（威圧）」ってなります。*ここではあえて話を合わせてあります。*
[^not-a-lie]: この表現に嘘はない。いいね？

この本で対象にするPandocのバージョンは**2.7.3**です。この本が出る頃には本家で
**2.8**が発表されているかもしれません[^quite-many-milestone-issues]が。

[^quite-many-milestone-issues]: 思ったよりもこなすべきIssueの数が多いので間に合うかもしれません。
これらのIssueは<https://github.com/jgm/pandoc/milestone/7>にまとめられています。

## 読者さんが持ってるといいかもしれない知識 {-}

もし、この本の読者さんに以下に挙げるような知識がちょっとずつでもあれば、理解が早まると思います。

### Shell {-}

- 途中で基本的なシェルスクリプトの例がちょびっとだけでてきます。ややこしい構文は使いません。

### Makefile {-}

- コンパイラの仕組みの根幹をなすアプリケーションです。後ほど解説します。
  枯れているので情報量が多いです。特殊な構文は使いませんし、筆者はよく知りません。

### Python {-}

- Pythonスクリプトというかパッケージの話題が出てきます。２系でも３系でも通じます
  （が、この本を読む頃には２系が完全にEOLですね）。

### Haskell {-}

- Pandocのソースを読むときにとても役に立ちます（が、筆者はHaskellの知識が全くありませんし文中にも出てきません）。

### Lua {-}

- 筆者の自作Luaフィルタのソース全文を載せるかもしれません。紙面の都合で載せないかもしれません。

### Open Office XML (ooxml/openxml) {-}

- Open Office XMLはWord・Excel・PowerPointファイルの内部言語です。
Word出力専用フィルタの解説でちょっと出てきますが、筆者もごく一部しかわかりません。

#### jgm's diff tool {-}

- Word・PowerPoint・ODT（OpenOfficeのファイル形式）・XMLの差分をみるときに使えるツールが
Pandocのソースツリーに入っています。実体は３０行程度のシェルスクリプトのようです。
筆者は使ったことがないですが、さわってみると面白いかもしれません。

### (Xe)LaTeX {-}

- PDF出力のエンジンに\XeLaTeX を使います。テンプレートを全文掲載するかもしれません。

### WSL （Windows Subsystem for Linux） {-}

- Windows Subsystem for LinuxことWSLは、Windows上で*Pandocker*を動作させるために必要です。
読者諸氏は全員Windows10・Mac・Linuxユーザとみなして解説します。時期的にも７は対象外です。
8.xは筆者が持ってないので対象外です。

### Docker {-}

- *Pandocker*の実体はDockerイメージです。イメージの依存関係とか設計？思想的なことを解説します。
Dockerfileを全文掲載するかもしれません。一行ずつ追いかけながら解説するかもしれません。

#### Docker (on Ubuntu) in WSL {-}

- WSLに入れるディストリビューションはDebian系とします。

# What is Pandoc?

Pandocは結局何者なのでしょうか。本家によると、
***「マークアップフォーマット変換の必要があるときに、スイスアーミーナイフにな（ってくれ）るもの」***らしいです。

> （<https://pandoc.org/>より抜粋）
>
> If you need to convert files from one markup format into another, pandoc is your swiss-army knife.

Pandocはたくさんの便利なMarkdown拡張文法を理解します。（中略）もし厳密なMarkdown文法のみを使いたければ、これらの
拡張機能はすべて無効にできます。

> Pandoc understands a number of useful markdown syntax extensions, including document metadata (title, author, date);
> footnotes; tables; definition lists; superscript and subscript; strikeout; enhanced ordered lists
> (start number and numbering style are significant); running example lists; delimited code blocks with syntax
> highlighting; smart quotes, dashes, and ellipses; markdown inside HTML blocks; and inline LaTeX. If strict markdown
> compatibility is desired, all of these extensions can be turned off.

## jgm（John MacFarlane）氏曰く

> **「Pandocを媒介にしてHaskellを広めたい」**（ちょっと大胆な意訳）
>
> > "I like to think of pandoc as a virus that spreads Haskell.\
> > (<https://github.com/jgm/pandoc/issues/1278#issuecomment-42502343>)

などとのたまっていますが、筆者には手が出せません。

## Convert to/from AST tree

Pandocのフォーマット変換は3段階に分かれています（[@fig:pandoc-conversion-diagram]）。最初のReaderが入力元のフォーマットを
中間形式（AST：Abstract Syntax Tree）に変換し、最後のWriterが中間形式から出力先フォーマットに再変換します。
後述するフィルタ（[@sec:pandocs-filters ]）はReaderが変換したASTに対する処理を行って、再びASTに戻します。

[Conversion diagram](data/ast-tree.bob){.svgbob #fig:pandoc-conversion-diagram }

### List of Inputs {#sec:list-of-inputs}

Pandocが受け付ける入力フォーマットは`--list-input-formats`で取得できます。これらは
`--from/-f`オプションに与えるパラメータです。これによってReaderを指定します。

Listing: 入力フォーマット一覧（`*`は筆者による） {#lst:list-input-formats}

``` bash
$ pandoc --list-input-formats

# 出力結果
commonmark *
creole
docbook
docx
epub
fb2
gfm
haddock
html
jats
json
latex
man
markdown *
markdown_github *
markdown_mmd *
markdown_phpextra *
markdown_strict *
mediawiki
muse
native
odt
opml
org
rst
t2t
textile
tikiwiki
twiki
vimwiki
```

#### Markdown方言への対応 {#sec:markdown-variants}

[@lst:list-input-formats]の通り、入力フォーマットは多岐にわたりますが、この本ではMarkdown
の派生フォーマット（いわゆる方言、リスト内 `*` マーク）に注目します。

Pandocは細かい機能を継ぎ足しすることでフォーマットごとの互換性を保っています。
また、フォーマットごとにデフォルトで決められたものに加えて、さらなる
拡張を有効または無効にできるように設計されています[^markdown-extentions]。たとえば`markdown_strict`では、
HTML記述以外の表を表として解釈しませんが、**`markdown_strict+pipe_tables`**とすると、
Pandocは`pipe_table`文法で書かれた表をパースします。あるいは`+east_asian_line_breaks`を明示しないと、
改行ごとに空白が挿入されてしまいます。これらの拡張の一覧を表示させるには、`--list-extentions`オプションをつけてPandocを実行します。

[^markdown-extentions]: <https://pandoc.org/MANUAL.html#extensions>

``` shell
$ pandoc --list-extensions
```

さらに`=[FORMAT]`を追加して`FORMAT` （[@lst:list-input-formats]から選択）を指定すると、
各`FORMAT`でどの拡張がデフォルトで有効になっているかを表示します。`markdown`の例を[@lst:markdown-extension-defaults]に
示します。

\newpage

[`markdown`フォーマットのデフォルト拡張一覧](data/markdown-extension-defaults.txt){.listingtable #lst:markdown-extension-defaults}

以下が各派生モードの大まかな説明です。<https://pandoc.org/MANUAL.html#markdown-variants>を要約しています。

##### **`markdown`** {-}

- Pandocの全拡張機能を使える派生フォーマットです。一部の非標準拡張（`emoji`など）は追加する必要があります。
- この本の対象フォーマットです。

##### **`markdown_strict`** {-}

- 最初の（最古の）Markdown実装の互換モードです。
- 拡張フラグ`raw_html`, `shortcut_reference_links`, `spaced_reference_links`がセットされています。

\newpage

##### **`gfm`/`commonmark`** {-}

- 読者諸氏にもおなじみのGitHub Flavored Markdown派生です。現在はCommonmarkを継承しています。
`pipe_table`、`emoji`などが使えます。
- 拡張フラグ`pipe_tables`, `raw_html`, `fenced_code_blocks`, `auto_identifiers`,\
`gfm_auto_identifiers`, `backtick_code_blocks`, `autolink_bare_uris`,\
`space_in_atx_header`, `intraword_underscores`, `strikeout`, `task_lists`, `emoji`,\
`shortcut_reference_links`, `angle_brackets_escapable`, `lists_without_preceding_blankline`
がセットされています。

##### **`markdown_mmd`** {-}

- MultiMarkdown互換モードです。筆者はよく知りません。
- 拡張フラグ`pipe_tables`, `raw_html`, `markdown_attribute`, `mmd_link_attributes`,\
`tex_math_double_backslash`, `intraword_underscores`, `mmd_title_block`, `footnotes`,\
`definition_lists`, `all_symbols_escapable`, `implicit_header_references`, `auto_identifiers`,\
`mmd_header_identifiers`, `shortcut_reference_links`, `implicit_figures`, `superscript`,\
`subscript`, `backtick_code_blocks`, `spaced_reference_links`, `raw_attribute`
がセットされています。

##### **`markdown_phpextra`** {-}

- PHP言語で拡張された派生フォーマット"PHP Markdown Extra"の互換モードです。筆者はよく知りません。
- 拡張フラグ`footnotes`, `pipe_tables`, `raw_html`, `markdown_attribute`, `fenced_code_blocks`,\
`definition_lists`, `intraword_underscores`, `header_attributes`, `link_attributes`,\
`abbreviations`, `shortcut_reference_links`, `spaced_reference_links`がセットされています。

### List of Outputs

Pandocが出力可能なフォーマットは[@sec:list-of-inputs]と同様に`pandoc --list-output-formats`で得られます。
[@sec:markdown-variants]で説明した拡張を有効・無効にする機能は、出力の際にも適用されます。

[出力フォーマット一覧](data/pandoc-output-formats.txt){.listingtable #lst:list-output-formats}

*Pandocker*ではHTML・DOCX・PDFに出力できます。

#### HTML

- Not CSS typesetting (yet)

#### PDF engines

- XeLaTeX

#### Word

- 2010

### Extensions

# #include "pandoc-syntax.md"
# #include "filters.md"
# #include "templates.md"
# #include "pandocker.md"
# #include "environment.md"

# Postface

- 書いててまとまりがなくて困ってる

## References
