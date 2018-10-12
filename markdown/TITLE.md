# まえがき {-}

このドキュメントは、技術書典3にて発表した「私的Markdown-PDF変換環境を紹介する本」とC93で発表した
続編「２」を再編集したもの[^compiled-by-docker]です。「２」の発表後も環境の更新は続けられていて
ちょっと合わなくなってきているので、追いかけながら書いていきます。

この本では、**pandoc_misc**環境で使用できる機能と使用方法、 環境を１から構築する手順[^scratch-is-not-required]、
Dockerイメージ、CI構築例を順に解説していきます。

[^compiled-by-docker]: もちろんこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。 しつこいですね

[^scratch-is-not-required]: いまさらスクラッチからの構築は不要なのですが、残します

このシリーズでは「MacまたはLinux機」を動作前提環境としていましたが、「２」以降は _Dockerがちゃんと動くWindows10機_
であれば簡単確実に動くようになったので、本当に
Dockerには感謝しています。もうGtk+まわりで悩まなくていいんだょ…[^company-machine]

Dockerがちゃんと動かないWindows機をお使いの方は外部のCIサービスを使ってください。

[^company-machine]: 筆者の会社支給のマシンはOSごと入れ直さないと動かないっぽいのでWindowsキライ

この本の内容で楽しんでもらうために読者さんに最低限済ませてほしいことはGitのインストールだけです。[^github-account]

[^github-account]: GitHubかBitBucketのアカウントがあるとCI構築ができるのでさらにしあわせですが、
                   ホスティングサービスにアップロードを行わずとも使えるビルド方法を説明しますので絶対に必要というわけでもないです。

# クイックスタート：とりあえず使ってみる編

CIなどを使わず、全てをローカルマシンで管理する前提[^dropbox]で「とりあえず使える」ようにします。

[^dropbox]: Dropboxとかを使うという手もあります。CIはできないですがGitのremoteリポジトリを置いておいて
            複数のマシンで共有することはできます。

#### Dockerのインストール {-}

Dockerの入手・導入は容易です。

- `dmg`(for Mac): https://www.docker.com/docker-mac
- `deb`(for Ubuntu): https://www.docker.com/docker-ubuntu
- installer (for Windows 10): https://www.docker.com/docker-windows

#### Whalebrewのインストール {-}

https://github.com/bfirsh/whalebrew#install に従ってWhalebrewを導入します。 Windowsユーザは別の方法をとります。

<!-- Windows版は https://github.com/3846masa/whalebrew#install に従います。 -->

#### Dockerイメージのダウンロード {-}

シェル上で`whalebrew install k4zuki/whalebrew-pandocker`を打ち込む。これだけです。
いい感じにインストールが行われたのち`/usr/local/bin/pandocker`として実行できるようになります。 Windowsでは`docker pull
k4zuki/pandocker`を打ち込んでください。

## で、何ができるん？何をするん？

- Pandocというドキュメント変換プログラムをコアにして、
- 各種プラグインの活躍により、
- Pandoc Flavored Markdownで書かれた原稿を、
- それなりに体裁が整った{PDFまたはHTML}に出力します。

出力にあたって必要なコマンドは主に

- `pandocker init`
- `pandocker html`あるいは`pandocker all`
- `pandocker pdf`
- `pandocker clean`

の４種類です。 引数なしの`pandocker`ではエラーになります。

### スクリプトを書く

WindowsのひとはPATHが通っている任意の場所に以下のような感じで実行スクリプトを置いてください。
本当はPowerShellがいいんですが筆者は詳しくない[^powershellpwd]のでbashの例を書きます。カレントディレクトリをマウントして
`docker run`する内容です。引数なしで実行するとコマンドプロンプトが出てきます。

[^powershellpwd]: Powershell流の現在ディレクトリの取得方法がわかれば書けます。

```{.sh #lst:pandocker_sh}
#!/usr/bin/env bash

docker run --rm -it -v $PWD:/workdir k4zuki/pandocker $@
```

#### 実行例 {-}

```sh
$ pandocker.sh # コマンドプロンプトになる
$ pandocker.sh make init|html|all|pdf|clean
$ pandocker.sh make # whalebrewでインストールした場合の`pandocker`コマンドと等価
```

今後登場する`pandocker XX`コマンドは`pandocker.sh make XX`と読み替えてください。

## 原稿リポジトリを作る

早速本を書く準備を整えます。 新規に原稿管理用Gitリポジトリを作りましょう。たとえば
ホームディレクトリ直下のworkspaceディレクトリにMyBookというGitリポジトリを作ります。

```sh
$ mkdir -p ~/workspace/MyBook # ~/workspaceディレクトリが存在しなければ同時に作る
$ cd ~/workspace/MyBook
$ git init
```

ここで原稿リポジトリにコンパイル環境をコピーします。 `pandocker init`の出番です。

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

## 原稿リポジトリをとりあえずコンパイルする

ここでいったんコンパイルできるかどうか試してみましょう。`TITLE.md`の中身が空でも
コンパイルすることはできます。コンパイルする前に`Makefile`/`config.yaml`と
原稿一式をリポジトリに登録して最初のコミットをします。

```sh
$ git add .
$ git commit -m"initial commit"
```

この状態で`pandocker html`とすると`Out/TARGET.html`というファイルができあがるはずです。 以下にコマンドの一覧を載せます。

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

### ファイル名・ディレクトリ名の設定(Makefile) {#sec:config-makefile}

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
,,,
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
,,
```

## 原稿を書く {#sec:pandoc}

これでとりあえずコンパイルが通るようになったので、実際の原稿を書けるようになりました。 Pandoc Flavored
Markdown記法に則って書いていきます。

### 必要なら、章ごとにファイルを分けてもいいよ {#sec:file-per-section}

編集方針(合同誌などの理由で複数人が原稿に関わるなど)によっては章ごとにファイルを分けたほうが無難でしょう。
方法は２つあります。

#### Makefileで設定する {.unnumbered #sec:config-by-makefile}

Makefileに複数の原稿ファイルを書き足していけばその順番どおり連結され、
連結されたものにコンパイル・フィルタ適用されます。下記の例なら`Appendix.md`が`TITLE.md`の直後に書かれていると
タイトルページの直後にAppendixが現れる構成になってしまいます。

```{.makefile #lst:makefile_example}
# CONFIG:= config.yaml
INPUT:= TITLE.md
INPUT += Section1.md
INPUT += Section2.md
INPUT += Appendix.md
# TARGET:= TARGET
```

#### GPPでプリプロセスする {.unnumbered #sec:use-gpp-preprocess}

Generic Preprocessor（汎用プリプロセッサ）^[https://github.com/logological/gpp]を使います。
プリプロセッサというのはC言語などで`＃include "stdio.h"`などと記述すると、予めヘッダファイルを
読み込んでおいてくれるあの機能を持ったプログラムのことです。
C言語風そのままだとヘッダと間違われるのでHTML風に`<＃include "ファイル名">`
と記述します。該当部分は指定されたファイルに置き換えられます(入れ子になっていても機能します)。
ファイル名は相対パス指定で動きます。予約されている`$(MDDIR)`、`$(DATADIR)`、`$(TARGETDIR)`
ディレクトリにあるファイルはファイル名指定のみで動作します。それぞれのデフォルト値は
[@sec:config-makefile]を参照ください。GPPの入れ子は２５６段階らしいです。

GPPの良くないところは **バックスラッシュ`\\`(または半角の`￥`)が1つだけ使われていると強制的に消されてしまうことです。**
_このドキュメントの原稿も2個重ねてあります。_

### ヘッダのナンバリングに関する注意

デフォルトの`config.yaml`では章番号がつく設定(`--number-sections`適用済)で、例外的に`{-}`または`{.unnumbered}`で
つけない設定にできます。が、つけずに済ませられるのは深さ４までの章番号に限られ、深さ５より深いものは _強制的に_
ナンバリングされます。_**バグっぽいんだけどどうなんですかね**_。 そこまで深く章分けする人あまりいないんですかね。

# 出力を整形する編

PDF出力を整形する方法を解説します。

## 直接記述TeXを駆使して整形する

TeX文を直書きしておくとPDF出力時にTeXコンパイラが処理してくれます。HTML出力を選択したときは無視されます。

```table
---
caption: TeX使用例
header: True
markdown: True
---
"TeX文","効果"
`\\newpage`,"即時強制改ページ（直後に空行を要する）"
`\\Begin{<env>}`~`\\End{<env>}`,"挟まれた部分に`<env>`環境を適用する"
```

## Pandocフィルタ（プラグイン）を使って整形する

Pandocは中間処理のための*フィルタ*というしくみを用意しています。簡単に言うとプラグインです。
フィルタを使うとCSVから表に変換して挿入したり、外部ファイルを引用したり、ページを回転したりできます。

**pandoc_misc**環境にインストールされているフィルタの概要一覧を下に示します。 次の項から１つずつ解説していきます。

\\newpage

:::::::::::::::::::::::::::::: rmnote

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
PANFLAGS += --filter=pandocker-tex-landscape
PANFLAGS += --filter=$(PCROSSREF)

TEXFLAGS += --filter=pandoc-latex-barcode
```

::::::::::::::::::::::::::::::

```table
---
caption: 導入済みフィルタ {#tbl:installed-filters}
header: True
markdown: True
alignment: DDCC
width:
  - 0.5
  - 0.2
  - 0.15
  - 0.15
---
"名前","参照先","HTML出力","PDF出力"
"`pandocker-rmnote`","[@sec:pandocker-rmnote]","Y","Y"
"`pantable`","[@sec:pantable]","Y","Y"
"`pandocker-listingtable(-inline)`",[@sec:pandocker-listingtable],"Y","Y"
"`pandocker-bitfield(-inline)`",[@sec:pandocker-bitfield],"Y","Y"
"`pandocker-wavedrom-inline`",[@sec:pandocker-wavedrom-inline],"Y","Y"
"`pandocker-aafigure(-inline)`",[@sec:pandocker-aafigure],"Y","Y"
"`pandocker-rotateimage(-inline)`",[@sec:pandocker-rotateimage],"Y","Y"
"`pandoc-imagine`",[@sec:pandoc-magine],"Y","Y"
"`pandoc-crossref`","[@sec:pandoc-crossref-filter]","Y","Y"
"`pandocker-tex-landscape`","[@sec:pandocker-tex-landscape]","N","Y"
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
,,,
```

\\newpage

### `pantable`フィルタ {#sec:pantable}

CSVファイルまたは直接記述で表を挿入するフィルタです。オプション設定でセル内のmarkdownを解釈するかどうかを設定できます。
CSVファイルが指定されているときは直接記述部分を無視します。

リポジトリURLはこちら: <https://github.com/ickc/pantable>

複数行セルはダブルクオート`"`ではさみます。セルにダブルクオートを含むときは予めエスケープします`\\"`。

以下にリポジトリのREADMEを抜粋します。

\\Begin{mdframed}

Optionally, YAML metadata block can be used within the fenced code block, following standard pandoc YAML metadata block
syntax. 7 metadata keys are recognized:

-   `caption`: the caption of the table. If omitted, no caption will be inserted. Default: disabled.
-   `alignment`: a string of characters among `L,R,C,D`, case-insensitive, corresponds to Left-aligned, Right-aligned,
    Center-aligned, > Default-aligned respectively. e.g. `LCRD` for a table with 4 columns. Default: `DDD...`
-   `width`: a list of relative width corresponding to the width of each columns. e.g.

    ```yaml
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
-   `include`: the path to an CSV file, can be relative/absolute. If non-empty, override the CSV in the CodeBlock.
    default: None

When the metadata keys is invalid, the default will be used instead. Note that width and table-width accept fractions as
well.

\\End{mdframed}

\\newpage

#### 使用例 {-}

"#tbl:"で始まるアンカーを書いておくと"Table X.Y: zzz"の形式で変換されます（下記参照）。

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
caption: オプションパラメータ一覧 {#tbl:pantable-options}
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
,,,
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

```{.listingtable #lst:block-listingtable-sample}
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
caption: オプションパラメータ一覧 {#tbl:listingtable-options}
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`caption`^[ブロック表記のとき。ハイパーリンク表記ではタイトル部(`[...]`)で指定する],,Y,ソースファイル名
`source`^[ブロック表記のとき。ハイパーリンク表記ではURL部で指定する],ソースファイル名(フルパス),N,
`type`,"ソースファイル種類(python,cpp,markdown etc.)",Y,plain
`from`,引用元ソースの切り出し開始行,Y,1
`to`,引用元ソースの切り出し終了行,Y,max
,,,
```

\\newpage

### `pandocker-bitfield(-inline)`フィルタ {#sec:pandocker-bitfield}

マイコンのデータシートに載っていそうな「ビットフィールド図」を挿入できるようにするフィルタです。
[@sec:pandocker-listingtable]と同様の文法が使えます。
"bitfield"そのものの文法は本家(<https://github.com/drom/bitfield>)を参照ください。

[@tbl:bitfield-options]にある出力オプションにかかわらず、HTML出力(`pandocker html`など)
するときはSVG、TeX/PDF出力(`pandocker pdf`など)のときはPDFにリンクします。EPSへの変換は指定がなければ行われず、
指定してもリンクされません。変換後のファイル名はランダムな16進数8桁です。
HTMLでもTeX/PDFでもないときはPNGをリンクします。

もともとの`bitfield`プログラムはJSONファイルから画像に変換するものですが、入力ファイルとして
YAMLも扱えるようになっています。内部で使うプログラムはオリジナルのJS製ではなく、
[pythonに移植したもの](https://github.com/K4zuki/bitfieldpy)を使っています。
JS(というか外部シェル)を使うのは殆どの場合問題がないんですが、Windows７機での意味不明な
エラー[^windows-io-error]が解決できず移植に踏み切りました。

[^windows-io-error]: たぶんpythonの"subprocess"周辺のエラーですが時間の無駄だし根が深そうなので追いかけてません。

#### 記述例 {-}

`````markdown
```{.bitfield #fig:block-bitfield-sample}
# input: # ソースファイル名
# png: # PNG出力フラグ
eps: True # EPS出力フラグ
pdf: True # PDF出力フラグ
lane-height: 80 # レーンあたりの高さ
lane-width: 640 # レーンの幅
lanes: 2 # レーンの数
bits: 32 # 総ビット数
fontfamily: "source code pro" # フォントファミリ名
fontsize: "16" # フォントサイズ
fontweight: "normal" # フォントのウェイト
caption: _**block bitfield sample**_ # タイトル
directory: "svg" # 出力ディレクトリ
attr: # 画像幅などの指定
  - width: 80%
---
# list from LSB
# bits: bit width
# attr: information RO/WO/RW etc.
# name: name of bitfield
- bits: 5
- bits: 1
  attr: RW
  name: IPO
- bits: 1
  attr: RW
  name: BRK
- bits: 1
  name: CPK
```

[**inline bitfield sample**](data/bitfields/bit.yaml){.bitfield pdf=True #fig:inline-bitfield-sample}

`````

```{.bitfield #fig:block-bitfield-sample}
caption: _**block bitfield sample**_
---
# list from LSB
# bits: bit width
# attr: information RO/WO/RW etc.
# name: name of bitfield
- bits: 5
- bits: 1
  attr: RW
  name: IPO
- bits: 1
  attr: RW
  name: BRK
- bits: 1
  name: CPK
```

[**inline bitfield sample**](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 pdf=True #fig:inline-bitfield-sample}

#### オプションパラメータ一覧 {-}

```table
---
caption: オプションパラメータ一覧 {#tbl:bitfield-options}
header: True
markdown: True
width:
  - 0.20
  - 0.40
  - 0.20
  - 0.20
alignment: DDCC
---
パラメータ,機能,省略可能,初期値
`input`,ソースファイル名,N,
`png`,PNG出力フラグ,Y,**True**
`eps`,EPS出力フラグ,Y,False
`pdf`,PDF出力フラグ,Y,False
`lane-height`,レーンあたりの高さ,Y,80
`lane-width`,レーンの幅,Y,640
`lanes`,レーンの数,Y,1
`bits`,総ビット数,Y,8
`fontfamily`,フォントファミリ名,Y,"source code pro"
`fontsize`,フォントサイズ,Y,16
`fontweight`,フォントのウェイト,Y,normal
`caption`,タイトル,Y,Untitled(*)
`directory`,出力ディレクトリ,Y,"`./svg`"
`attr`,画像幅などの指定,Y,
```

(*) インライン形式のときはタイトルなしにできる

\\newpage

### `pandocker-wavedrom-inline`フィルタ {#sec:pandocker-wavedrom-inline}

ロジック回路（など）のタイミング図を挿入できるようにするフィルタです。JSONまたはYAMLファイルへの
ハイパーリンク表記のみ使えます。文法は本家チュートリアル(<http://wavedrom.com/tutorial.html>)を参照ください。
本家よりもJSONの文法を厳密に解釈します(<https://github.com/BreizhGeek/wavedrompy#important-notice>)。
また、本家チュートリアル2(<http://wavedrom.com/tutorial2.html>)の回路図レンダリングは未実装です。

本家はJS製（サーバサイド用途を前提にしているように見受けられる）ですが、先述のSubprocess問題を回避するため、
Python移植版(<https://github.com/BreizhGeek/wavedrompy>)をさらにフォークしてライブラリとして使用しています。

`````markdown
[wavedrom sample](data/waves/anotherwave.yaml){.wavedrom #fig:inline-wavedrom-example}
`````

[wavedrom sample](data/waves/anotherwave.yaml){.wavedrom #fig:inline-wavedrom-example}

<!-- ```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
``` -->

\\newpage

### `pandocker-aafigure(-inline)`フィルタ {#sec:pandocker-aafigure}

アスキーアートを画像に変換してくれるフィルタです。内部ではaafigure(<https://github.com/aafigure/aafigure>)
を使っています。[@sec:pandocker-listingtable]と同様の文法が使えますが、直接記述は右下がりの斜め線描画に難があります。
aafigureの文法はヘルプページ<http://aafigure.readthedocs.io/en/latest/>を参照ください

`````markdown
```{.aafigure #fig:block-aafigure}
# input: data/bitfields/bit.yaml
caption: _**block aafigure sample**_
png: True
pdf: True
---
A   B
 AA   BB
 AA   BB

  ---- |         ___  ~~~|
       | --  ___|        |    ===
                         ~~~
/-------\\\\
| "foo" |
+-------+
| "bar" |
\\\\-------/
                                     +
      |  -  +   |  -  +   |  -  +   /               -
     /  /  /   /  /  /   /  /  /   /     --     |/| /    +
    |  |  |   +  +  +   -  -  -   /     /  \\\\        -   \\\\|/  |\\\\
                                 +     +    +          +-+-+ | +
    |  |  |   +  +  +   -  -  -   \\\\     \\\\  /        -   /|\\\\  |/
     \\\\  \\\\  \\\\   \\\\  \\\\  \\\\   \\\\  \\\\  \\\\   \\\\     --     |\\\\| \\\\    +
      |  -  +   |  -  +   |  -  +   \\\\               -
                                     +

    --->   | | | | | |
    ---<   | | | | | |
    ---o   ^ V v o O #
    ---O
    ---#
```

[inline aafigure sample](data/aafigure.txt){.aafigure #fig:inline-aafigure png=True pdf=True eps=True}
`````

```{.aafigure #fig:block-aafigure}
# input: data/bitfields/bit.yaml
caption: _**block aafigure sample**_
png: True
pdf: True
---
A   B
 AA   BB
 AA   BB

  ---- |         ___  ~~~|
       | --  ___|        |    ===
                         ~~~
/-------\\
| "foo" |
+-------+
| "bar" |
\\-------/
                                     +
      |  -  +   |  -  +   |  -  +   /               -
     /  /  /   /  /  /   /  /  /   /     --     |/| /    +
    |  |  |   +  +  +   -  -  -   /     /  \\        -   \\|/  |\\
                                 +     +    +          +-+-+ | +
    |  |  |   +  +  +   -  -  -   \\     \\  /        -   /|\\  |/
     \\  \\  \\   \\  \\  \\   \\  \\  \\   \\     --     |\\| \\    +
      |  -  +   |  -  +   |  -  +   \\               -
                                     +

    --->   | | | | | |
    ---<   | | | | | |
    ---o   ^ V v o O #
    ---O
    ---#
```

[inline aafigure sample](data/aafigure.txt){.aafigure #fig:inline-aafigure png=True pdf=True eps=True}

```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`input`,ソースファイル名,N,
`png`,PNG出力フラグ,Y,**True**
`eps`,EPS出力フラグ,Y,False
`pdf`,PDF出力フラグ,Y,False
```

\\newpage

### `pandocker-rotateimage(-inline)`フィルタ {#sec:pandocker-rotateimage}

シンプルな画像回転フィルタです。wavedrom/bitfield/aafigureとの組み合わせ、拡大縮小も可能です。
wavedrom/bitfield/aafigureと組み合わせた場合はSVG/PDF画像の回転を試みます。 _angle_
指定が正の数で時計回り、負の数は反時計回りです。実際の _angle_ は360で割った余りを用います。 _angle=365_
なら右に5度回転します。

`````markdown
[inline aafigure sample](data/aafigure.txt){.aafigure #fig:inline-aafigure-30 png=True pdf=True eps=True .rotate angle=30 height=40%}

[wavedrom sample](data/waves/anotherwave.yaml){.wavedrom #fig:inline-wavedrom-example-m30 .rotate angle=-30 height=40%}
`````

\\newpage

[inline aafigure sample](data/aafigure.txt){.aafigure #fig:inline-aafigure-30 png=True pdf=True eps=True .rotate
angle=30 height=40%}

[wavedrom sample](data/waves/anotherwave.yaml){.wavedrom #fig:inline-wavedrom-example-m30 .rotate angle=-30 height=40%}

:::::{#fig:RotateImage}

[0](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 height=25% width=25%}

[30](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=30 height=25% width=25% #fig:RotateImageA}
[60](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=60 height=25% width=25% #fig:RotateImageB}
[90](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=90 height=25% width=25% #fig:RotateImageC}
[120](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=120 height=25% width=25% #fig:RotateImageD}

[150](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=150 height=25% width=25% #fig:RotateImageE}
[180](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=180 height=25% width=25% #fig:RotateImageF}
[210](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=210 height=25% width=25% #fig:RotateImageG}
[240](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=240 height=25% width=25% #fig:RotateImageH}

[270](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=270 height=25% width=25% #fig:RotateImageI}
[300](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=300 height=25% width=25% #fig:RotateImageJ}
[330](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=330 height=25% width=25% #fig:RotateImageK}
[360](data/bitfields/bit.yaml){.bitfield bits=32 lanes=2 .rotate angle=360 height=25% width=25% #fig:RotateImageL}

回転サンプル

:::::

```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`angle`,relative path to source file,N,0
,,,
```

\\newpage

### `pandoc-imagine`フィルタ(PlantUML) {#sec:pandoc-magine}

巷にあふれる各種テキスト−画像コンバータプログラムをラップしたフィルタです。出力はPNGファイルになるので、
特にPDF出力にするときはできあがりの画像サイズに注意しないとブロックノイズでガタガタになります。
ファイル指定はできず直接記述のみに対応します。おすすめはGPPによる取り込みです。
下の例はPlantUMLでditaaのダイアグラムをレンダリングさせる例です。gnuplotとかも使えるらしいです。

より詳しいことは本家GitHubページ<https://github.com/hertogp/imagine>を参照ください。

`````markdown
```{.plantuml im_out="img" caption="PlantUML x ditaa x imagine"}
<#include "ditaa.puml">
```
`````

\\newpage

```{.plantuml im_out="img" caption="PlantUML x ditaa x imagine"}
<#include "ditaa.puml">
```

::::::::::::::::::::::::::::::::::: rmnote

```table
---
caption: オプション一覧
header: True
markdown: True
---
パラメータ,機能,省略可能,初期値
`param`,function,Y,true
```

:::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::: rmnote

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

:::::::::::::::::::::::::::::::::::

\\newpage

### `pandoc-crossref`フィルタ {#sec:pandoc-crossref-filter}

言わずと知れた超有名Haskell製フィルタです。図・コードブロック・表・セクションの相互参照テーブル
を組み立てます。複数の画像を並べて一つの参照番号にすることもできます。その時はそれぞれに小番号がつきます。

より詳しくは<http://lierdakil.github.io/pandoc-crossref>を参照ください。

`````markdown
### Section {#sec:section-title}

![Title](path/to/image.png){#fig:figure-title-single}

Table: Table title {#tbl:table-title}

|   type   |       id       |
|----------|----------------|
| Section  | #sec:<link id> |
| Figure   | #fig:<link id> |
| Table    | #tbl:<link id> |
| Code     | #lst:<link id> |
| Equation | #eq:<link id>  |

:::::{#fig:imagearray}
![1st image](/path/to/first/image.png){#fig:imagearray1}
![2nd image](/path/to/second/image.png){#fig:imagearray2}

![3rd image](/path/to/third/image.png){#fig:imagearray3}
![4th image](/path/to/forth/image.png){#fig:imagearray4}

Image Array
:::::

$$ E = mc^2 $$ {#eq:emcsquared}
`````

\\newpage

### `pandocker-tex-landscape`[^progress] {#sec:pandocker-tex-landscape}

一時的にTeXのgeometry設定を横長（ランドスケープ）に変更するフィルタです。"LANDSCAPE"クラスのdiv節に適用されます。

`````markdown
:::::::::::::::::::::::::::::: LANDSCAPE
[**pandocker-base**イメージのDockerfile](pandocker-base/Dockerfile){.listingtable type=dockerfile #lst:pandocker-base-dockerfile}

[**pandocker**イメージのDockerfile](pandocker/Dockerfile){.listingtable type=dockerfile #lst:pandocker-dockerfile}
::::::::::::::::::::::::::::::
`````

処理結果は[@lst:pandocker-base-dockerfile]を参照ください。

[^progress]: ところでこのフィルタは**技術書典４本番の１週間前に実装しました**（原稿の進捗を推して知るべし）。

```markdown
# 深さ1：章番号なし {.unnumbered}
## 深さ2：章番号なし {.unnumbered}
### 深さ3：章番号なし {.unnumbered}
#### 深さ4：章番号なし {.unnumbered}
##### 深さ5+：章番号復活 {.unnumbered}
```

# 変換を自動化する編

ここまでインストール以外をオフラインで済ませる方法を解説してきましたが、原稿が進んでくるといちいち
コマンドを打ち込むのが面倒になってきます。そこでPDF/HTMLへの変換をどこかのサーバでやらせる方法
を例示していきます。筆者はGitHubとCircleCIで連携したシステムにしましたが、読者諸氏のお気に入りのやり方があるのであれば
GitHub＋CircleCIの組み合わせに固執する理由はありません。

## GitHubのアカウントを取得する

GitHubのガイドページ<https://guides.github.com/activities/hello-world/>やどこかのQiita -
たとえばここ：[**GitHubアカウント作成とリポジトリの作成手順 on \\@Qiita**](https://qiita.com/kooohei/items/361da3c9dbb6e0c7946b)
を参考に登録します。

## GitHubアカウントを使用してCircleCIに登録する

CircleCIのサインアップページ<https://circleci.com/signup/>に行って[Sign Up With GitHub]をクリックし、ガイドに従って
GitHubアカウントを連携させます。
ここが参考になります：[**GitHubとCircleCIを連携させる on \\@Qiita**](https://qiita.com/kooohei/items/4806fdb6b92982e47f81)

## GitHub上でWebHookを設定する

筆者のconfig.ymlは最後のステップでリリースページにファイルをアップロードします。
このアップロード権限をCircleCIに与える方法についてはこのページが最も参考になります
（とくにアクセストークンの登録のあたり）：
[**PHP_CodeSniffer GitHub CircleCIでコードレビューの自動化**](https://engineers.weddingpark.co.jp/?p=1080)

アップロードを必要としない場合はslackに投げつけるなどを思いつきますが、_やり方はわかりません_。

## CIの設定ファイルをリポジトリ内に用意する

CircleCIの設定ファイルをリポジトリ内の指定の場所(`/.circleci/config.yml`)に用意します。

最初の5行でk4zuki/pandockerイメージを取得します。

[](.circleci/config.yml){.listingtable to=5}

そのあとの`checkout`のタイミングでリポジトリのクローンが行われます。直後にリポジトリ内のサブモジュールを取得しています。

[](.circleci/config.yml){.listingtable from=5 to=10}

そのあとは`run`ブロックを順次実行していきます。途中`git rev-parse --short
HEAD`がたびたび登場して寿限無っぽくなってますが 適切なやり方がわからないのでそのままです。

[](.circleci/config.yml){.listingtable from=10}

"Prepare QR code for this build"ブロックでGitHubのリリースページURLからQRコード画像を生成します。
各CIビルドが終わるとHTMLとPDFファイルをコミットIDに関連付けた名前でリリースしますが（Deploy
preparation/Deployブロック）、
このQR画像ファイル名は固定しておいて、原稿内にこのファイル名を参照するように画像リンクを置いておけば、
ビルドされたPDF/HTMLからリリースページに即ジャンプできます。即売会でのダウンロード販売が楽になります。

# あえて環境を構築してみる編

## なにもないところからaptかbrewで構築する修行の章

### インストールそしてインストールそれからインストール

インストールしまくります。

### パッケージ管理ツールのインストール

#### Homebrew(Mac) - https://brew.sh/index_ja.html {-}

全てに先んじてHomebrewのインストールをします。

```sh
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Ubuntuユーザはaptがほぼ全てやってくれるので特別にインストールするものはありません

### 言語のインストール

主に２言語使います - **Python*３*・LaTeXです**。
Pythonはフィルタとシェルスクリプトの代わり、そしてLaTeXはPDF出力のためです。
従来はHaskellとNodeJS(npm)も必要としていましたが、npmモジュールはWindows上の動作に問題がありPythonに移植されたものを
使うので削除、Haskellはコンパイル済バイナリを入手するだけで済むことがわかったので不要となりました。

#### Mac {.unnumbered}

```sh
$ brew install python3
$ brew cask install mactex
$ brew install wget
```

#### Ubuntu {.unnumbered}

```sh
$ sudo apt-get install python3 python3-pip
$ sudo apt-get install texlive-xetex
```

参考サイト： https://texwiki.texjp.org

### 各言語のパッケージのインストール

#### Mac {.unnumbered}

```sh
$ wget -c https://github.com/jgm/pandoc/releases/download/2.1.3/pandoc-2.1.3-macOS.pkg
# インストーラが /usr/local/bin/pandoc にインストールしてくれる
$ wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.0.2/osx-ghc82-pandoc21.tar.gz
$ tar zxf osx-ghc82-pandoc21.tar.gz
$ sudo mv pandoc-crossref /usr/local/bin/

$ pip3 install pyyaml pillow
$ pip3 install pantable csv2table
$ pip3 install six pandoc-imagine
$ pip3 install svgutils
$ pip3 install git+https://github.com/K4zuki/wavedrompy.git
$ pip3 install git+https://github.com/K4zuki/bitfieldpy.git
$ pip3 install git+https://github.com/K4zuki/pandocker-filters.git
$ pip3 install git+https://github.com/pandocker/removalnotes.git
$ pip3 install git+https://github.com/pandocker/tex-landscape.git

$ wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip
$ unzip v0.4.zip
$ sudo mkdir -p /usr/local/texlive/2015basic/texmf-local/BXptool/
$ sudo cp BXptool-0.4/bx*.{sty,def} /usr/local/texlive/2015basic/texmf-local/BXptool/
$ sudo mktexlsr
$ tlmgr install oberdiek
```

<!-- pandoc-crossrefがpandocに依存しているので自動的にインストールされます。 -->

#### Ubuntu {.unnumbered}

aptで入るpandocは1.16でだいぶ古いのでpandocのGitHubサイト^[https://github.com/jgm/pandoc/releases]
からdebファイルを落としてきます

```sh
$ wget -c https://github.com/jgm/pandoc/releases/download/2.1.3/pandoc-2.1.3-1-amd64.deb
$ sudo dpkg -i pandoc-2.1.3-1-amd64.deb
$ wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.0.2/linux-ghc82-pandoc21.tar.gz
$ tar zxf linux-ghc82-pandoc21.tar.gz
$ sudo mv pandoc-crossref /usr/local/bin/

$ sudo -H pip3 install pyyaml pillow
$ sudo -H pip3 install pantable csv2table
$ sudo -H pip3 install six pandoc-imagine
$ sudo -H pip3 install svgutils
$ sudo -H pip3 install git+https://github.com/K4zuki/wavedrompy.git
$ sudo -H pip3 install git+https://github.com/K4zuki/bitfieldpy.git
$ sudo -H pip3 install git+https://github.com/K4zuki/pandocker-filters.git
$ sudo -H pip3 install git+https://github.com/pandocker/removalnotes.git
$ sudo -H pip3 install git+https://github.com/pandocker/tex-landscape.git

$ sudo apt-get install xzdec texlive-lang-japanese
$ tlmgr init-usertree
$ tlmgr option repository ftp://tug.org/historic/systems/texlive/2015/tlnet-final
$ wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip
$ unzip v0.4.zip
$ sudo mkdir -p /usr/share/texlive/texmf-dist/tex/latex/BXptool/
$ sudo cp BXptool-0.4/bx*.{sty,def} /usr/share/texlive/texmf-dist/tex/latex/BXptool/
$ sudo mktexlsr
$ tlmgr install oberdiek
```

### ツールのインストール

#### Mac {.unnumbered}

```sh
$ brew install librsvg gpp
```

#### Ubuntu {.unnumbered}

```sh
$ sudo apt-get install librsvg2-bin gpp
$ sudo apt-get install graphviz
```

### フォントのインストール

各リポジトリからアーカイブをダウンロード・解凍してTTFファイル(TrueTypeフォント)を全部、
ユーザフォントディレクトリにコピーします。

```sh
mkdir -p $HOME/.local/share/fonts/
cd $HOME/.local/share/fonts/
wget -c https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip
wget -c https://github.com/adobe-fonts/source-sans-pro/archive/2.020R-ro/1.075R-it.zip
wget -c https://github.com/mzyy94/RictyDiminished-for-Powerline/archive/3.2.4-powerline-early-2016.zip
```

### PlantUMLのダウンロード・インストール

homebrew/aptで入手できるバージョンは古いので直接ダウンロード・インストールします。

```sh
curl -fsSL https://sourceforge.net/projects/plantuml/files/plantuml.1.2017.18.jar/download -o /usr/local/plantuml.jar
echo "#!/bin/bash" > /usr/local/bin/plantuml
echo "java -jar /usr/local/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml
chmod +x /usr/local/bin/plantuml
```

### ツールキット"pandoc_misc"のダウンロード

ビルドスクリプトのMakefileが収められたリポジトリです。`$(HOME)/.pandoc`にクローンします。
`--recursive`オプションでサブモジュールも同時にクローンされます。

```sh
$ cd ~/.pandoc
$ git clone --recursive -b 0.0.24 https://github.com/K4zuki/pandoc_misc.git
```

ここまでやって*運が良ければ*`make init -f ~/.pandoc/pandoc_misc/Makefile`、\\ `make clean/all/html/tex/pdf`が動きます。
筆者も上記の内容で動いていたのですが、**とくにMacの環境構築は昨年後半から更新しておらず検証不足であり、**
**バージョン間の相性が発生するかもしれません。**

## Dockerでﾗｸﾁﾝﾔｯﾀｰの章

上記のリスキーなインストール祭りを(その後のメンテナンス地獄を最小化するため)Dockerイメージで置き換えます。
構築に際して考えることが少なく済むように、Ubuntu16.04をベースイメージにします。この本が出る頃には
もしかすると*18.04*が登場しているかもしれません[^ubuntu1804]が気にしません。

[^ubuntu1804]: 調べてみたらこの原稿が落ちない限り、技術書典４の時点ではファイナルβですね ->
               <https://wiki.ubuntu.com/BionicBeaver/ReleaseSchedule>

### 基本Dockerイメージ(pandocker-base)と最終形態(pandocker)を切り分ける

最終的に実用するDockerイメージはTeXLiveを含めなければならずビルドに時間がかかるので、 イメージ作成を2段階にしました：

- TeXを含めイメージ構築上必要なもの一式でバージョンが変化しにくいもの[^notex]を一つのイメージ(**pandocker-base**)
  にまとめました。pandocker-baseイメージはUbuntu公式が用意しているUbuntu16.04LTSの最小構成イメージを継承し、
  apt-getなどで必要なものを追加していきます。
- 自作pythonパッケージはできるだけ頻繁にpipでアップデートしていきたいので、**pandocker**イメージにまとめます。
  ツールキットpandoc_miscのダウンロードもこちらのイメージで行います。

[^notex]: Git、TeX、Python(pip)、Pandoc、フォントなど。TeXが不要な環境向けに*notex*ブランチも用意してあります。

:::::::::::::::::::::::::::::: LANDSCAPE

pandocker-base/pandockerイメージのDockerfileを以下に全文掲載します。

[**pandocker-base**イメージのDockerfile](pandocker-base/Dockerfile){.listingtable type=dockerfile
#lst:pandocker-base-dockerfile}

[**pandocker**イメージのDockerfile](pandocker/Dockerfile){.listingtable type=dockerfile #lst:pandocker-dockerfile}
::::::::::::::::::::::::::::::

# Appendix {-}

### Web Hook Tree {-}

備忘録として：今まで挙げたGitHub／DockerHubリポジトリは互いに依存関係があります。依存関係ツリーを以下に示しておきます。

```{.plantuml im_out="img"}
<#include "webhooktree.puml">
```

# 更新履歴 {-}

## Revision1.0（技術書典４） {-}

- **このセクションは本番2日前の金曜日の21時頃に書かれました。FMP4を見たいので急いで書かれました**
- （まるまる１週間原稿追い込み有給休暇を取ったのに半分をﾌoｰｸﾗｲ5に費やした程度には）進捗ダメです！
- 半角120文字くらいで折り返しで1100行でPDF56ページ分です（500行超えたあたりでスクロールがめんどくなった）
- フォントはコードブロックに*Ricty Diminished*、地の文（？）に *源の角ゴシック* を使っています。
- PDFが欲しいだと？この文章を読んでいるときに紙の本が売り切れていたなら下のQRコードを読んでいいぞ;-)

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}
