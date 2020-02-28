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

筆者が今までに作ったPandable系フィルタはほぼ全てLuaフィルタに置き換わっています。一部Pythonライブラリを直接扱うものと、
PandocのLua APIで実現できないものはそのまま使っています。

## Lua made

jgmのおすすめはLuaフィルタです。PandocがLuaインタプリタ（実行環境）を内蔵し、個別の実行環境を
導入する必要がないからです。Pandocのメーリングリストでもフィルタを書くようにすすめるときはLuaフィルタを
例に出すことが多くなっています。

### Speed

Pythonのフィルタはそんなに速くありません。Luaフィルタはオーバーヘッドが少ない（？）のでそれに比べると
十分速いです。Python系[^pantable-url]と同等の機能をLuaで実装したところ１０倍速く^[pantable使用で5分かかっていたものが30秒に]
なりました。あまりいいベンチマークではないですが、参考まで。

## Extensions by filters
### Common behavior

出力の形式にかかわらず適用されるフィルタ群です。

### [*Cross reference*]{.underline} {-}

- pandoc-crossref (<https://lierdakil.github.io/pandoc-crossref>、`--filter=pandoc-crossref`)

章・節タイトル、図と表、コードリスト、数式に相互参照機能を実装するフィルタです。図をタイル状に並べて小番号をつける機能もあります
が、DOCX出力ではちょっと工夫が必要です。
作者はPandocの開発にも関わっていて、とくにDOCX周りで色々貢献しています。

[デフォルト値一覧](data/pandoc-crossref-defaults.yaml){.listingtable type=yaml}

図・表・コードリストの一覧（Table of Tables、Table of Figures、Table of Listings）を生成するTeXコマンドも用意されています。

### [*CSV to table*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=csv2table.lua`)

CSVファイルをPandocの表に変換するLuaフィルタです。CSVファイルへのURLリンクに`table`クラス属性がついたものに対し
発動します。 `header`、`width`、`alignment`、`subset_from`、`subset_to`、`nocaption`オプション属性を持ちます。

### [*Listing*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=listingtable.lua`)

任意のテキストファイルをソースコードの引用に変換するフィルタです。テキストファイルへのURLリンクに`listing`
クラス属性がついたものに対し発動します。`from`、`startFrom`、`to`、`type`、`numbers`、`nocaption`オプション属性を持ちます。

### [*Preprocess*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=preprocess.lua`)

任意のテキストファイルを原稿ファイルとして取り込むフィルタです。任意レベルの見出しが

1. `#include`
1. `<空白文字>`
1. `"<取り込みたいファイル名>"`

という順番になっている場合に発動します。取り込みたいファイルが見つからない場合はエラーメッセージを吐きますが、
エラーは出しません。

### [*Block comment*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=removable-note.lua`)

### [*SVG to PNG/PDF at runtime*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=svgconvert.lua`)

SVG画像へのリンクを見つけると、出力形式に応じてPDFかPNGに変換するフィルタです。HTML・HTML５が指定されていると
SVGのまま何もしません。
変換のためにrsvg-convertを呼び出すので、あらかじめインストールされている必要があります。

### [*Table width*]{.underline} {-}

- pandocker-lua-filters (`--lua-filter=table-width.lua`)

表の列幅をページ幅からの割合で指定できるようにするフィルタです。`table`クラス属性がつけられているdiv節の中に
表が一つだけ置かれている場合に、divの中の表に対して作用します。オプションとして`width`と`noheader`が用意されています。

### [*AAFigure*]{.underline} {-}

- pandocker-pandoc-filters (`--filter=pandocker-filters`)

### [*svgbob*]{.underline} {-}

- pandoc-svgbob-filter (`--filter=pandoc-svgbob-filter`)

### [*blockdiag*]{.underline} {-}

- pandoc-blockdiag-filter (`--filter=pandoc-blockdiag-filters`)

### HTML only behavior

### LaTeX only behavior

#### Landscape

- pandocker-lua-filters
```markdown
::: LANDSCAPE

:::
```

##### Table coloring

- pandocker-lua-filters

##### Pagebreak

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

### Word only behavior
##### Table of Contents

- pandocker-lua-filters
```markdown
<!--blank-->
\toc
<!--blank-->
```

##### Forced Page break

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

##### Unnumbered headings

- pandocker-lua-filters
```markdown
# Unnumbered Heading 1 {-}
## Unnumbered Heading 2 {-}
### Unnumbered Heading 3 {-}
#### Unnumbered Heading 4 {-}
```

##### Centering Image

- pandocker-lua-filters

### Post processing
##### docx-core-property-writer
