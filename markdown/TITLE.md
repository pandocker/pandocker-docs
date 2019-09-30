\newpage

\newpage

\toc

# はじめに {-}

このドキュメントは、Pandocベースのドキュメントコンパイラ*Pandocker*をできるだけ細かく・詳しく・網羅的に
解説する本です。Pandocの国内"エンジニア"[^strict-engineer-definition] 界隈での知名度が上がってきたことで、Pandoc系ドキュメントコンパイラ[^not-a-lie]
とか言っておけば食いつきがいいかもなどという妥協と、シリーズ化して差分しか掲載せずにいると売れ行きが良くないため、
周辺情報をまとめた「総集編２」を出します。

[^strict-engineer-definition]: ちなみに筆者は「エンジニア」の*\underline{定義}*原理主義者です。
[^not-a-lie]: この表現は嘘ではない。いいね？

## 読者さんが持ってるといいかもしれない知識 {-}

もし、この本の読者さんに以下に挙げるような知識がちょっとずつでもあれば、理解が早まると思います。

- [x] Shell
  - 途中で基本的なシェルスクリプトの例がちょびっとだけでてきます。ややこしい構文は使いません。
- [x] Makefile
  - コンパイラの仕組みの根幹をなすアプリケーションです。後ほど解説します。
  枯れているので情報量が多いです。特殊な構文は使いませんし、筆者はよく知りません。
- [x] Python
  - Pythonスクリプトというかパッケージの話題が出てきます。２系でも３系でも通じます
  （が、この本を読む頃には２系が完全にEOLですね）。
- [x] Haskell
  - Pandocのソースを読むときにとても役に立ちます（が、筆者はHaskellの知識が全くありませんし文中にも出てきません）。
- [x] Lua
  - 筆者の自作Luaフィルタのソース全文を載せるかもしれません。紙面の都合で載せないかもしれません。
- [x] Open Office XML (ooxml/openxml)
  - Open Office XMLはWord・Excel・PowerPointファイルの内部言語です。
  Word出力専用フィルタの解説でちょっと出てきますが、筆者もごく一部しかわかりません。
  - [x] jgm's diff tool
    - Word・PowerPoint・ODT（OpenOfficeのファイル形式）・XMLの差分をみるときに使えるツールが
    Pandocのソースツリーに入っています。実体は３０行程度のシェルスクリプトのようです。
    筆者は使ったことないですが、さわってみると面白いかもしれません。
- [x] (Xe)LaTeX
  - PDF出力のエンジンに\XeLaTeX を使います。テンプレートを全文掲載するかもしれません。
- [x] WSL
  - Windows Subsystem for LinuxことWSLは、Windows上で*Pandocker*を動作させるために必要です。
  読者諸氏は全員Windows10・Mac・Linuxユーザとみなして解説します。時期的にも７は対象外です。
  ８は筆者が持ってないので対象外です。
- [x] Docker
  - *Pandocker*の実体はDockerイメージです。イメージの依存関係とか設計？思想的なことを解説します。
  Dockerfileを全文掲載するかもしれません。一行ずつ追いかけながら解説するかもしれません。
  - [x] Docker (on Ubuntu) in WSL
    - WSLに入れるディストリビューションはDebian系とします。

# What is Pandoc?

Pandocは、本家によると「マークアップフォーマット変換の必要があるときに、スイスアーミーナイフにな（ってくれ）るもの」です。

> If you need to convert files from one markup format into another, pandoc is your swiss-army knife.

## jgm（John MacFarlane）氏曰く

「Pandocを媒介にしてHaskellを広めたい

> "I like to think of pandoc as a virus that spreads Haskell.
>> <https://github.com/jgm/pandoc/issues/1278#issuecomment-42502343>

## Haskell

## Convert to/from AST tree

### List of Inputs

Pandocが受け付ける入力フォーマットは`--list-input-formats`で取得できます。

Listing: 入力フォーマット一覧（`*`は筆者による） {#lst:list-input-formats}

```bash
$ pandoc --list-input-formats

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

#### Markdown Parsers

[@lst:list-input-formats]の通り、入力フォーマットは多岐にわたりますが、この本ではMarkdown
の派生フォーマット（リスト内`*`マーク）にのみ注目します。

#### Pandoc's Markdown

### List of Outputs

#### HTML

- Not CSS typesetting (yet)

#### PDF engines

- XeLaTeX

#### Word

- 2010

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

- pandoc-crossref

#### CSV to table

- pandocker-lua-filters

#### Listing

- pandocker-lua-filters

#### Preprocess

- pandocker-lua-filters

#### Block comment

- pandocker-lua-filters

#### SVG to PNG/PDF at runtime

- pandocker-lua-filters

#### Table width

- pandocker-lua-filters

#### AAFigure

- pandocker-pandoc-filters

#### svgbob

- pandoc-svgbob-filter

#### blockdiag

- pandoc-blockdiag-filter

#### SVG to PNG/PDF

- pandocker-lua-filters

### HTML only behavior
### LaTeX only behavior
#### Landscape

- pandocker-lua-filters

#### Table coloring

- pandocker-lua-filters

#### Pagebreak

- pandocker-lua-filters

### Word only behavior
#### Table of Contents

- pandocker-lua-filters

#### Forced Page break

- pandocker-lua-filters

#### Unnumbered headings

- pandocker-lua-filters

#### Centering Image

- pandoc-docx-utils-py

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

- Base image
- Extending image

#### 18.04

- Base image
- Extending image

## Installation
### Mac
### Linux
### Windows
## Document

# Writer's Environment

この章では筆者の執筆環境を紹介していきます。

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
