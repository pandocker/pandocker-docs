# Pandocの「フィルタ」について {#sec:pandocs-filters }

Pandoc単体ではできないことでも、「フィルタ」を通すことで機能を拡張できます。つまり、プラグインのようなものです。

## おさらい：フィルタのしくみ

PandocフィルタはPandoc ASTに対して処理を行い、再度Pandoc ASTにして次のプログラムに渡します([@fig:pandoc-conversion-diagram-2; @sec:convert-to-from-ast-tree])。

[Conversion diagram (再掲)](data/ast-tree.bob){.svgbob #fig:pandoc-conversion-diagram-2 height=50mm}

PandocはASTをネイティブ(`-t native`)またはJSON（`-t json`）に出すことができます。このため、
各言語のJSONライブラリをちょっと利用すればフィルタを書くことはできます。jgm本人がいくつかの言語のために用意した
ライブラリもあります。

## Haskell made

PandocがHaskellで書かれていることから、Pandocのライブラリを最も自然に利用できるHaskellで書かれたフィルタが多数存在します。
Haskell系フィルタの代表例は`pandoc-crossref`[^pandoc-crossref-url]です。

[^pandoc-crossref-url]: <https://lierdakil.github.io/pandoc-crossref>

なお筆者はHaskell言語でプログラムを書いたことがないのでフィルタも書けません。

## Panflute/python made

筆者は最近よくPythonを使っているので、最初にフィルタを作りたくなったときはPython系のPanfluteライブラリ[^panflute-url] を
採用しました。代表的なPanflute系フィルタは`pantable`[^pantable-url] です。

[^panflute-url]: <http://scorreia.com/software/panflute>
[^pantable-url]: <https://ickc.github.io/pantable>

### 筆者の自作フィルタは一部を除きLuaフィルタに置き換え済み

筆者が今までに作ったPandable系フィルタはほぼ全てLuaフィルタに置き換わっています。一部Pythonライブラリを直接扱うものは
そのまま使っています。

## Lua made

jgmのおすすめはLuaフィルタです。PandocがLuaインタプリタ（実行環境）を内蔵し、個別の実行環境を
導入する必要がないからです。Pandocのメーリングリストでもフィルタを書くようにすすめるときはLuaフィルタを
例に出すことが多くなっています。

### Speed

## Extensions by filters
### Common behavior
#### Cross reference

- pandoc-crossref (<https://lierdakil.github.io/pandoc-crossref>)

[デフォルト値一覧](data/pandoc-crossref-defaults.yaml){.listingtable type=yaml}

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
```markdown
::: LANDSCAPE

:::
```

#### Table coloring

- pandocker-lua-filters

#### Pagebreak

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

### Word only behavior
#### Table of Contents

- pandocker-lua-filters
```markdown
<!--blank-->
\toc
<!--blank-->
```

#### Forced Page break

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

#### Unnumbered headings

- pandocker-lua-filters
```markdown
# Unnumbered Heading 1 {-}
## Unnumbered Heading 2 {-}
### Unnumbered Heading 3 {-}
#### Unnumbered Heading 4 {-}
```

#### Centering Image

- pandocker-lua-filters

### Post processing
#### docx-core-property-writer
