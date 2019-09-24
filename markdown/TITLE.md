\newpage

\newpage

\toc

# はじめに {-}

このドキュメントは、Pandocベースのドキュメントコンパイラ*Pandocker*をできるだけ細かく・詳しく・網羅的に
解説する本です。Pandocの国内"エンジニア"界隈で知名度が上がってきたことと、シリーズ化してきて

## 読者さんが持ってるといいかもしれない知識 {-}

もし、この本の読者さんに以下に挙げるような知識がちょっとずつでもあれば、理解が早まると思います。

### Shell {-}

途中で基本的なシェルスクリプトの例がちょびっとだけでてきます。ややこしい構文は使いません。

### Makefile {-}

コンパイラの仕組みの根幹をなすアプリケーションです。後ほど解説します。
枯れているので情報量が多いです。特殊な構文は使いませんし、筆者はよく知りません。

### Python {-}

Pythonスクリプトというかパッケージの話題が出てきます。２系でも３系でも通じます
（が、この本を読む頃には２系が完全にEOLですね）。

### Haskell {-}

Pandocのソースを読むときにとても役に立ちます（が、筆者はHaskellの知識が全くありませんし文中にも出てきません）。

### Lua {-}

筆者の自作Luaフィルタのソース全文を載せるかもしれません。紙面の都合で載せないかもしれません。

### Open Office XML (ooxml/openxml) {-}

Open Office XMLはWord・Excel・PowerPointファイルの内部言語です。
Word出力専用フィルタの解説でちょっと出てきますが、筆者もごく一部しかわかりません。

#### jgm's diff tool {-}

Word・PowerPoint・ODT（OpenOfficeのファイル形式）・XMLの差分をみるときに使えるツールが
Pandocのソースツリーに入っています。実体は３０行程度のシェルスクリプトのようです。
筆者は使ったことないですが、さわってみると面白いかもしれません。

### (Xe)LaTeX {-}

PDF出力のエンジンに\XeLaTeX を使います。テンプレートを全文掲載するかもしれません。

### WSL {-}

Windows Subsystem for LinuxことWSLは、Windows上で*Pandocker*を動作させるために必要です。
読者諸氏は全員Windows10ユーザとみなして解説します。時期的にも７は対象外です。８は筆者が持ってないので対象外です。

### Docker {-}

*Pandocker*の実体はDockerイメージです。イメージの依存関係とか設計？思想的なことを解説します。
Dockerfileを全文掲載するかもしれません。一行ずつ追いかけながら解説するかもしれません。

#### Docker (on Ubuntu) in WSL {-}

WSLに入れるディストリビューションはDebian系とします。

# What is Pandoc?
## jgm
## Haskell
## Convert to/from AST tree
### List of Inputs
#### Markdown Parsers
#### Pandoc's Markdown
### List of Outputs
#### HTML
##### Not CSS typesetting (yet)
#### PDF engines
##### XeLaTeX
#### Word
##### 2010
### Extensions

# Syntax
## Text
### Italic
### Bold
### Bold Italic
## Image link
## File Link
## Footnotes
## Heading
### Unnumbered
## Bullet lists
### Ordered
### Unordered
### Task lists
## Inline HTML
## Inline LaTeX
## Table
### pipe_tables
### grid_tables
## Div
## Span
### Underline
## Equations
## Metadata

# Filters
## Shell pipe (ref)
## Haskell made
## Lua made
### Speed
## Panflute/python made
## Extensions by filters
### Common behavior
#### Cross reference
##### pandoc-crossref
#### CSV to table
##### pandocker-lua-filters
#### Listing
##### pandocker-lua-filters
#### Preprocess
##### pandocker-lua-filters
#### Block comment
##### pandocker-lua-filters
#### SVG to PNG/PDF at runtime
##### pandocker-lua-filters
#### Table width
##### pandocker-lua-filters
#### AAFigure
##### pandocker-pandoc-filters
#### svgbob
##### pandoc-svgbob-filter
#### blockdiag
##### pandoc-blockdiag-filter
#### SVG to PNG/PDF
##### pandocker-lua-filters
### HTML only behavior
### LaTeX only behavior
#### Landscape
##### pandocker-lua-filters
#### Table coloring
##### pandocker-lua-filters
#### Pagebreak
##### pandocker-lua-filters
### Word only behavior
#### Table of Contents
##### pandocker-lua-filters
#### Forced Page break
##### pandocker-lua-filters
#### Unnumbered headings
##### pandocker-lua-filters
#### Centering Image
##### pandoc-docx-utils-py
### Post processing
#### docx-core-property-writer

# Templates
## HTML
## LaTeX
### metadata
#### front
#### verbcolored
#### secnumdepth
## Word
### Paragraph and Table styles

# Pandocker
## Logic
### Make
### System config
#### Makefile.in
#### Makefile
#### config.yaml
### Project's config
#### Makefile
#### config.yaml
## Docker Images
### Alpine
#### 3.10
#### pandoc's official latex image
### Ubuntu
#### 16.04
##### Base image
##### Extending image
#### 18.04
##### Base image
##### Extending image
## Installation
### Mac
### Linux
### Windows
## Document

# Writer's Environment
## Another war crisis but
## VS Code/Atom
## JetBrains IDE
### PyCharm
### External Tools
### Live Templates
#### For Pandoc's markdown
#### For pandoc-crossref
#### For pandocker-lua-filters

# Postface
## References
