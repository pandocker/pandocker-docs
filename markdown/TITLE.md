# まえがき {-}

このドキュメントは、技術書典3にて発表した「私的Markdown-PDF変換環境を紹介する本」とC93で発表した
続編「２」を再編集したもの[^compiled-by-docker]です。「２」の発表後も環境の更新は続けられていて
ちょっと合わなくなってきているので、追いかけながら書いていきます。

この本では、**pandoc_misc**環境で使用できる機能と使用方法、
環境を１から構築する手順[^scratch-is-not-required]、
Dockerイメージ、CI構築例を順に解説していきます。

[^compiled-by-docker]: もちろんこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。
しつこいですね
[^scratch-is-not-required]: いまさらスクラッチからの構築は不要なのですが、残します

このシリーズでは「MacまたはLinux機」を動作前提環境としていましたが、「２」以降は
_Dockerがちゃんと動くWindows10機_ であれば簡単確実に動くようになったので、本当に
Dockerには感謝しています。もうGtk+まわりで悩まなくていいんだょ…[^company-machine]

[^company-machine]: 筆者の会社支給のマシンはOSごと入れ直さないと動かないっぽいのでWindowsキライ

この本の内容で楽しんでもらうために読者さんに最低限済ませてほしいことはたぶん
Gitのインストールを済ませておくことだけです。GitHubアカウントがあると楽ですが
必要というわけでもないです。

# 使ってみる編
#### Dockerのインストール {-}
Dockerの入手・導入は容易です。

- `dmg`(for Mac): https://www.docker.com/docker-mac
- `deb`(for Ubuntu): https://www.docker.com/docker-ubuntu
- installer (for Windows 10): https://www.docker.com/docker-windows

#### Whalebrewのインストール {-}
https://github.com/bfirsh/whalebrew#install に従ってWhalebrewを導入します。
<!-- Windows版は https://github.com/3846masa/whalebrew#install に従います。 -->

#### Dockerイメージのダウンロード {-}
シェル上で`whalebrew install k4zuki/pandocker-whalebrew`を打ち込む。これだけです。
いい感じにインストールが行われたのち`/usr/local/bin/pandocker`として実行できるようになります。

## で、何ができるん？何をするん？

- Pandocというドキュメント変換プログラムをコアにして、
- 各種プラグインの活躍により、
- Pandoc Flavored Markdownで書かれた原稿を、
- それなりに体裁が整った{PDFまたはHTML}に出力します。

出力にあたって必要なコマンドは主に

- `pandocker init`
- `pandocker html`あるいは`pandocker make`
- `pandocker pdf`
- `pandocker clean`

の４種類です。

## 原稿リポジトリを作る
早速本を書く準備を整えます。
新規に原稿管理用Gitリポジトリを作りましょう。たとえば
ホームディレクトリ直下のworkspaceディレクトリにMyBookというGitリポジトリを作ります。
```sh
$ mkdir -p ~/workspace/MyBook
$ cd ~/workspace/MyBook
$ git init
```
ここで原稿リポジトリにコンパイル環境をコピーします。
`pandocker init`の出番です。
```sh
$ pandocker -f /var/pandoc_misc/Makefile init
```
初期状態では以下のようなディレクトリ構成のはずです。
```
~/workspace/MyBook
|-- .circleci/
|   `-- config.yml
|-- .gitignore
|-- Makefile
|-- Out/
|-- images/
|-- markdown/
|   |-- TITLE.md
|   `-- config.yaml
`-- data/
```

\\newpage

## 原稿リポジトリをコンパイル
ここでいったんコンパイルできるかどうか試してみましょう。`TITLE.md`の中身が空でも
コンパイルすることはできます。コンパイルする前に`Makefile`/`config.yaml`と
原稿一式をリポジトリに登録して最初のコミットをします。
```sh
$ git add .
$ git commit -m"initial commit"
```
この状態で`pandocker html`とすると`Out/TARGET.html`というファイルができあがるはずです。
以下にコマンドの一覧を載せます。

```table
---
caption: コンパイルコマンド一覧 {#tbl:compile-commands}
markdown: True
width:
    - 0.3
    - 0.3
    - 0.4
---
コマンド,効果,成果物
`pandocker make init`,ディレクトリ初期化,
`pandocker make html`,HTMLファイル生成,`$(TARGETDIR)/$(TARGET).html`
`pandocker make pdf`,PDFファイル生成,`$(TARGETDIR)/$(TARGET).pdf`
`pandocker make clean`,成果物を全部消去,`rm -rf $(TARGETDIR)/*`
```

`make pdf` を使うとXeLaTeXを使ってPDFに出力します。表紙、目次、本文、奥付けが体裁されたPDFができあがるはずです。

## 原稿リポジトリの調整
原稿のファイル名・置き場所・ディレクトリ構成は自由に配置してください。日本語ファイル名は
問題ないと思います^[推奨しません]が、全角半角関係なく[^zenkaku]スペースを入れるのは避けるべきです。

[^zenkaku]: 読者諸氏は全角スペースをファイル名に使うような素人さんではないと信じたい

### ファイル名・ディレクトリ名の設定(Makefile) {.unnumbered}
タイトルファイル名、ディレクトリ名を変更した場合は、そのことをビルドスクリプトに知らせる必要があります。
ビルドスクリプトはタイトルページのファイル名と各種ディレクトリ名をMakefileから取得します。
ディレクトリ名はすべてMakefileが置かれたディレクトリからの相対パスです。

\\newpage
[Makefile](Makefile){.listingtable type=makefile}
```table
---
caption: Makeコンパイルオプション
width:
  - 0.15
  - 0.2
  - 0.5
  - 0.15
header: True
markdown: True
---
変数名,種類,意味,初期値
`CONFIG`,ファイル,pandocのコンフィグファイル,`config.yaml`
`INPUT`,ファイル,タイトルファイル,`TITLE.md`
`TARGET`,ファイル,出力ファイル,`TARGET`
`MDDIR`,ディレクトリ,原稿markdownファイルの置き場所,`markdown/`
`DATADIR`,ディレクトリ,データディレクトリ,`data/`
`TARGETDIR`,ディレクトリ,出力先ディレクトリ,`Out/`
`IMAGEDIR`,ディレクトリ,画像ファイルの置き場所,`images/`
```

\\newpage
### Pandocオプションの設定(config.yaml) {#sec:yaml-metadata}
Pandocはmarkdownファイル内のYAML FrontMatterもしくは独立したYAMLファイルから
コンパイルオプションを取得します。これらの値は表紙絵と奥付に使用されます
```table
---
caption: Pandocコンパイルオプション
header: True
markdown: True
width:
  - 0.2
  - 0.5
  - 0.3
---
パラメータ,意味,初期値
`title`,タイトル,本のタイトル
`abstract`,サブタイトル,本の概要
`circle`,サークル名,サークル名
`author`,作者の名前,本の作者
`comiket`,イベント名,コミケ
`year`,発行年,出版年
`publisher`,印刷所,出版社で印刷製本
`docrevision`,リビジョン番号,1.0
`front`,表紙画像ファイル名,`images/front-image.png`
`verbcolored`,\\`verbatim\\`に枠線をつけるフラグ,false(枠なし)
`rmnote`,pandocker-rmnoteフィルタでコンパイル時に`<div class="rmnote">`〜`</div>`を消すフラグ,false(残す)
```

## 原稿を書く {#sec:pandoc}
これでとりあえずコンパイルが通るようになったので、実際の原稿を書けるようになりました。
**~~デファクトスタンダードこと~~**Pandoc Flavored Markdown記法に則って書いていきます。

### Pandocフィルタ（プラグイン）一覧
**pandoc_misc**環境にインストールされているフィルタの概要一覧を下に示します。
次の項から１つずつ解説していきます。

<div class="rmnote">
```makefile
PANFLAGS += --filter=pandocker-rmnote
PANFLAGS += --filter=$(PANTABLE)
PANFLAGS += --filter=pandocker-listingtable
PANFLAGS += --filter=pandocker-listingtable-inline
PANFLAGS += --filter=pandocker-bitfield
PANFLAGS += --filter=pandocker-bitfield-inline
PANFLAGS += --filter=pandocker-wavedrom-inline
PANFLAGS += --filter=pandocker-aafigure
PANFLAGS += --filter=pandocker-aafigure-inline
PANFLAGS += --filter=pandocker-rotateimage
PANFLAGS += --filter=pandocker-rotateimage-inline
PANFLAGS += --filter=$(IMAGINE)
PANFLAGS += --filter=$(PCROSSREF)

TEXFLAGS += --filter=pandoc-latex-barcode
```
</div>
```table
---
caption: 導入済みフィルタ
header: True
markdown: True
---
名前,機能,HTML出力,PDF出力,参照先
`pandocker-rmnote`,`<div class="rmnote">`から`</div>`までの区間を削除する,Y,Y,[@sec:pandocker-rmnote]
`pantable`,CSVファイルまたは直打ちで表を挿入する,Y,Y,[@sec:pantable]
`pandocker-listingtable(-inline)`,外部ファイルを引用する,Y,Y,[@sec:pandocker-listingtable]
`pandocker-bitfield(-inline)`,外部ファイルまたは直打ちでbitfield図を挿入する,Y,Y,
`pandocker-wavedrom-inline`,外部ファイルまたは直打ちでwavedrom波形を挿入する,Y,Y,
`pandocker-aafigure(-inline)`,外部ファイルまたは直打ちでaafigure図を挿入する,Y,Y,
`pandocker-rotateimage(-inline)`,画像を任意角度に回転する,Y,Y,
`pandoc-imagine`,各種外部プログラムを使った図を挿入する,Y,Y,
`pandoc-crossref`,超有名な相互参照リンカ,Y,Y,
`pandoc-latex-barcode`,QRコードを挿入する,N,Y,
```
\\newpage
### `pandocker-rmnote`フィルタ {#sec:pandocker-rmnote}
条件付きコメントアウトを実現するフィルタです。`pandoc -M rmnote:true`や[@sec:yaml-metadata]などで
`rmnote`メタデータに`true`を与えると`<div class="rmnote">`と`</div>`の間を削除します。
`rmnote`メタデータのデフォルト値は`false`です。
`````markdown
<div class="rmnote">
ここはコメント
</div>
`````
#### オプションパラメータ一覧 {-}
```table
---
caption: オプションパラメータ一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`rmnote`,削除フラグ,Y,false
```
\\newpage

### `pantable`フィルタ {#sec:pantable}
CSVファイルまたは直打ちで表を挿入するフィルタです。オプション設定でセル内のmarkdownを解釈するかどうかを設定できます。
CSVファイルが指定されているときは直打ち部分を無視します。

リポジトリURLはこちら: <https://github.com/ickc/pantable>

複数行セルはダブルクオート`"`ではさみます。セルにダブルクオートが含まれるときはエスケープします`\\"`。

以下にリポジトリのREADMEを抜粋します。

\\Begin{mdframed}

Optionally, YAML metadata block can be used within the fenced code block, following standard pandoc YAML metadata block syntax. 7 metadata keys are recognized:

-   `caption`: the caption of the table. If omitted, no caption will be inserted. Default: disabled.
-   `alignment`: a string of characters among `L,R,C,D`, case-insensitive, corresponds to Left-aligned, Right-aligned, Center-aligned, > Default-aligned respectively. e.g. `LCRD` for a table with 4 columns. Default: `DDD...`
-   `width`: a list of relative width corresponding to the width of each columns. e.g.
    ``` yaml
    - width
        - 0.1
        - 0.2
        - 0.3
        - 0.4
    ```
    Default: auto calculated from the length of each line in table cells.

-   `table-width`: the relative width of the table (e.g. relative to `\linewidth`). default: 1.0
-   `header`: If it has a header row or not. True/False/yes/NO are accepted, case-insensitive. default: True
-   `markdown`: If CSV table cell contains markdown syntax or not. Same as above. Default: False
-   `include`: the path to an CSV file, can be relative/absolute. If non-empty, override the CSV in the CodeBlock. default: None

When the metadata keys is invalid, the default will be used instead. Note that width and table-width accept fractions as well.

\\End{mdframed}

\\newpage

#### 使用例 {-}
`````markdown
```table
---
caption: 表のタイトル {#tbl:table-title}
# pandoc-crossrefのアンカー指定もできる
header: True # １行目をヘッダにする
markdown: True # セル内のmarkdownを解釈する
alignment: CCCC # 列ごとの文字寄せ指定
width: # 列ごとの幅割合指定
    - 0.3
    - 0.3
    - 0.2
    - 0.2
table-width: 0.8 # 表の幅
---
パラメータ,機能,省略可能,初期値
`foo`,hoge,Y,true
"`bar`","piyo","Y","
- `true` if A
- `false` if not A
"
```
`````

#### オプションパラメータ一覧 {-}
```table
---
caption: オプションパラメータ一覧
header: True
markdown: True
alignment: DDCC
---
パラメータ,機能,省略可能,初期値
`caption`,表のタイトル,Y,
`header`,ヘッダ行の有無,Y,True
`markdown`,セルをmarkdownとして解釈,Y,False
`alignment`,列ごとの文字寄せ,Y,DDD...
`width`,列ごとの幅割合,Y,"いい感じに  \
自動補正"
`table-width`,"表の幅(ページ幅に対する割合;  \
PDF出力のみ効果あり)",Y,1.0
`include`,外部ファイル使用時のファイル名,Y,
```
\\newpage
### `pandocker-listingtable(-inline)`フィルタ {#sec:pandocker-listingtable}
テキストファイルを引用して、タイトル付きのコードブロックに変換します。pantable(@sec:pantable)
と同様のYAMLコードブロック記述とハイパーリンク記述が使用できます。ハイパーリンク記述の前後には
改行を入れる必要があります。
`````markdown
``` {.listingtable #lst:block-listingtable-sample}
caption: caption
source: README.md
type: markdown
from: 5
to: 12
---
```
<!-- 改行 -->
[Sample inline listingtable](README.md){.listingtable type=markdown from=5 to=12 #lst:inline-listingtable-sample}
<!-- 改行 -->
- コードブロック記述へのリファレンス：[@lst:block-listingtable-sample]
- ハイパーリンク記述へのリファレンス：[@lst:inline-listingtable-sample]
`````

``` {.listingtable #lst:block-listingtable-sample}
caption: caption
source: README.md
type: markdown
from: 5
to: 12
---
```

[Sample inline listingtable](README.md){.listingtable type=markdown from=5 to=12 #lst:inline-listingtable-sample}

- コードブロック記述へのリファレンス：[@lst:block-listingtable-sample]
- ハイパーリンク記述へのリファレンス：[@lst:inline-listingtable-sample]

#### オプションパラメータ一覧 {-}
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`caption`^[ブロック表記のとき。ハイパーリンク表記ではタイトル部(`[...]`)で指定する],,Y,ソースファイル名
`source`^[ブロック表記のとき。ハイパーリンク表記ではURL部で指定する],ソースファイル名(フルパス),N,
`type`,"ソースファイル種類(python,cpp,markdown etc.)",Y,plain
`from`,引用元ソースの切り出し開始行,Y,1
`to`,引用元ソースの切り出し終了行,Y,max
```
\\newpage
#### `pandocker-bitfield(-inline)`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandocker-wavedrom-inline`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandocker-aafigure(-inline)`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandocker-rotateimage(-inline)`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandoc-imagine`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandoc-latex-barcode`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```
\\newpage
#### `pandoc-crossref`
`````markdown
`````
```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```

### ヘッダのナンバリングに関する注意
デフォルトの`config.yaml`では章番号がつく設定(`--number-sections`適用済)で、例外的に`{-}`または`{.unnumbered}`で
つけない設定にできます。が、つけずに済ませられるのは深さ４までの章番号に限られ、深さ５より深いものは
_強制的に_ ナンバリングされます。_**バグっぽいんだけどどうなんですかね**_。
そこまで深く章分けする人あまりいないんですかね。

```markdown
# 深さ1：章番号なし {.unnumbered}
## 深さ2：章番号なし {.unnumbered}
### 深さ3：章番号なし {.unnumbered}
#### 深さ4：章番号なし {.unnumbered}
##### 深さ5+：章番号復活 {.unnumbered}
```
# 構築してみる編
## なにもないところからaptかbrewで構築する修行の章
## Dockerでﾗｸﾁﾝﾔｯﾀｰの章
# Appendix {-}
### Web Hook Tree {-}
今まで挙げたGitHub／DockerHubリポジトリは互いに依存関係があります。依存関係ツリーを以下に示しておきます。
主に自分のためです。

```{.plantuml im_out="img"}
<#include "webhooktree.puml">
```
