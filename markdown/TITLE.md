# まえがき {-}

このドキュメントは、技術書典４にて発表した「私的Markdown-PDF変換環境を紹介する本３」の内容を
Windowsユーザ、特にMSWordと戦う必要がある皆さんに向けて再編集したものです。
Pandoc＋Docxの環境は他の方も研究しているのでN番煎じです。いままでこのシリーズでは
*さんざん忌避されてきた*MSWordあるいはDocxファイルですが、ついに手を出します。嫌だけど。

## 前提環境 {-}

この本では、WSL及びWord2010以降が動作するWindows10機[^company-machine]を
対象環境にします。OSバージョンは1803以降を前提にします。
半自動ローカルビルドについても言及するのでできればJerBrains系IDEが入っていると
いいと思います。文中では*PyCharm*を例に使います。
今更いうほどでもないですがこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。
原稿とテンプレートDocxファイルの編集、フィルタの動作確認はMacで行われました。

[^company-machine]: 筆者の会社支給のマシンはOS更新してもDockerとの相性問題が残るし突然の
シャットダウン現象が治らないしベンダーは遅延戦法で修理実行まで1ヶ月以上かかったしその割に
修理そのものは2時間しなかったしWindows嫌い

WSLがちゃんと動かないWindows機をお使いの方は、*手元でのコンパイルを諦めて*
外部CIサービスを利用してください。

この本は、`pandocker`の更新情報、新しいフィルタの紹介、初のWindowsユーザ向け環境構築ガイド、
テンプレート作成例、ローカルビルド実行までを取り扱います。

# `pandocker`はまた更新されました
## `pandoc_misc`をpipでインストールできるようにした

`pandocker`フレームワークは`pandoc_misc`というgitリポジトリを`/var`直下に置いて、
Makefileなどの参照先にしています。このリポジトリにはPandocに与えるオプションや
TeX・HTML出力のためのテンプレートファイルが用意されています。これらは従来
`/var`に直接クローンしてくる必要がありましたが、pipでインストールできるようにしました。

この変更によって、初期ファイル一式をインストールする`pandoc-misc-init`スクリプトが用意され、
特に新規に文書リポジトリを作るときのセットアップが楽になりました。**ただし、あらかじめ
Dockerイメージ`k4zuki/pandocker`をpullする必要があります。**

### インストール {-}

```bash
pip3 install git+https://github.com/k4zuki/pandoc_misc.git@pandocker
```

## LaTeX用オプションを追加

次節とも関連しますが、LaTeX出力のレベル５ヘッダにナンバリングされる問題がずっと続いていましたが、
マニュアルに設定オプションがあることを発見しました^[<https://pandoc.org/MANUAL.html#variables-for-latex>]。

この中の`secnumdepth`を**3**にするとうまくいくことがわかったので、デフォルト値を
`pandoc_misc/config.yaml`に追記しました。このファイルはシステムデフォルト値を保存するために用意してあります。
この値は原稿リポジトリ内の`markdown/config.yaml`に追記することで上書きできると思います。

## Docx出力専用フィルタを追加

Docxファイルの取扱は本当に面倒[^dont-think-anyone-oppose]ですが、少しでもマシな使い勝手になるように
Pandocフィルタをいくつか作りました。

[^dont-think-anyone-oppose]: これは個人の感想ですが、あまり強固に反論する人もいないんではないかなって

### `pandoc-docx-pagebreakpy`フィルタ

`pandoc-docx-pagebreak`というHaskell製フィルタを参考にしています。Pythonで書かれています。

pagebreakの名の通り原稿内の`\\newpage`を改ページに変換します。おまけとして`\\toc`を目次に変換します。
`\\toc`はテンプレート内の`TOC Header`（`目次の見出し`）スタイルが適用されます。このフィルタと同時に
pandocに`--toc`オプションを与えると目次が*２回出現*するので注意してください。`\\newpage`ないし`\\toc`の
前後は必ず空行が必要です。

#### インストール {.unnumbered}

```bash
pip3 install git+https://github.com/pandocker/pandoc-docx-pagebreak-py
```

#### サンプルコード {-}

Listing: markdown.md {#lst:markdown-md}

```markdown
# レベル１ヘッダ

ここはまえがきとか

\\toc

この上に目次が出現、この直後で改ページ

\\newpage

### レベル３ヘッダ

改ページの直後
```

#### フィルタ適用例 {-}

`-F`/`--filter`オプションに`pandoc-docx-pagebreakpy`を与えるだけです。

```bash
pandoc -t docx -F pandoc-docx-pagebreakpy markdown.md -o docx.docx
```

### `pandoc-docx-utils`フィルタ

Docxを扱うときに微妙に使いづらく感じる点をちょっと改善するフィルタです。Pythonで書かれています。

今のところ２つの機能が実装されています([@sec:apply-style-to-images]、[@sec:unnumbered-headers])。
いずれの機能もテンプレート内に追加のスタイル定義を必要とします。テンプレート内で定義されていない場合も
各スタイルが適用されますが、それらは`Normal`（"標準"）スタイルを継承したものになります。

#### インストール {-}

```bash
pip3 install git+https://github.com/pandocker/pandoc-docx-utils-py.git
```

#### 機能１：画像に任意のスタイルを適用する {#sec:apply-style-to-images}

##### 困り所

デフォルトのDocx出力では、段落中でない画像引用は必ず左寄せになってしまいます。

##### この機能の使い方

1. あらかじめテンプレートに画像引用時に使いたいスタイルを用意します。
1. Markdownの画像引用に`custom-style`オプションを追加し、用意したスタイル名を与えます[^with-other-filters]。
    - `custom-style`オプションを省略すると`Image Caption`スタイルを適用します。テンプレート内で
    `Image Caption`スタイルを左寄せに設定している場合は画像も左寄せになります。

[^with-other-filters]: bitfieldやwavedromのフィルタとも併用できますが、その場合はフィルタの呼び出し順に注意が必要です。

オプション省略時のスタイル名を変更したい場合はPandocのメタデータに`image-div-style`を加え、
スタイル名を与えます。ただし、*ここで与えるスタイル名はタイトルにも適用されることに注意してください。*

##### サンプルコード

この例では"Centered"クラスを予め用意しておく必要があります。

Listing: markdown.md {#lst:markdown-md-2}

```markdown
---
image-div-style: "Centered"
---

![sample image](images/QRcode.png){custom-style="Centered"}
 
[sample bitfield image](data/bitfields/bit.yaml){.bitfield custom-style="Centered" #fig:centered-image} 

![`Image Div`](images/QRcode.png){#fig:image-div-style} 
```

[sample bitfield image](data/bitfields/bit.yaml){.bitfield custom-style="Image Caption" #fig:centered-image}

#### 機能２：`unnumbered`指定されたヘッダに番号なしスタイルを適用する {#sec:unnumbered-headers}
##### 困りポイント

Pandocはデフォルトで見出しに番号を振らず、`--number-sections`というオプションを追加することで
対応します。このオプションを有効にしつつ例外的に番号なしにしたい場合は見出しに`{-}`もしくは
`{.unnumbered}`をつけることでフラグを立ててPandocに知らせます。PandocはDocx出力のときはこのルールを
*無視*します[^word-matter]。

[^word-matter]: これはWordの仕様の問題で、番号つき・番号なしで2種類のスタイルを予め用意しなければ
ならないからだと思われます。

##### この機能の使い方

1. あらかじめ`Heading Unnumbered 1``Heading Unnumbered 2`/`Heading Unnumbered 3`/`Heading Unnumbered 4`
という番号なし見出しスタイルを用意しておきます。
2. Markdownの見出しに`{-}`または`{.unnumbered}`フラグを与えます。

`unnumbered`フラグがつけられているレベル１から４の見出しのスタイル(`Heading 1` ~ `Heading 4`)を
"番号なし"(`Heading Unnumbered 1` ~ `Heading Unnumbered 4`)に変更します。これらのスタイル名を変更したい場合は
yamlメタデータに`heading-unnumbered`を加え、各見出しレベルごとにスタイル名を与えます。

```yaml
---
heading-unnumbered:
  1: "Heading Unnumbered" # default is "Heading Unnumbered 1"
  2: "Heading Unnumbered 2"
  3: "Heading Unnumbered 3"
  4: "Heading Unnumbered 4"
---
```

レベル５以下の細かい見出しレベルについては、(1)レベル５をデフォルトで番号なしとみなし、
(2)*レベル６〜９は使わないだろう*という前提です[^constasnt-outline-level]。

[^constasnt-outline-level]: 任意のスタイル名を用意させずとも`Heading 6`~`9`ヘッダスタイルを
利用できればと思ったのですが、`Heading X`組み込みスタイルはアウトラインレベルが固定されているようなので、
目次に出すことができず、断念しました。

##### サンプルコード

Listing: markdown.md {#lst:markdown-md-3}

```markdown
# Heading Unnumbered 1 {-}
## Heading Unnumbered 2 {-}
### Heading Unnumbered 3 {-}
#### Heading Unnumbered 4 {-}
##### Heading Unnumbered 5 {-}
```

#### フィルタ適用例 {-}

`-F`/`--filter`オプションに`pandoc-docx-utils`、`--reference-doc`にテンプレートファイル名を与えます。
メタデータを与える場合は`-M`オプションを使います。`pandoc-crossref`と併用するときはこのフィルタをあとに記述します。

```bash
# standard usage
pandoc -t docx -F pandoc-docx-utils --reference-doc=template.docx markdown.md -o docx.docx

# cooperate with bitfield filter
pandoc -t docx -F pandocker-bitfield-inline -F pandoc-docx-utils --reference-doc=template.docx markdown.md -o docx.docx

# image link styled in "Center"
pandoc -t docx -F pandoc-docx-utils --reference-doc=template.docx -M image-div-style="Center" markdown.md -o docx.docx

# cooperate with pandoc-crossref filter
pandoc -t docx -F pandoc-crossref -F pandoc-docx-utils --reference-doc=template.docx markdown.md -o docx.docx
```

## アスキーアートレンダリング系フィルタを追加
### `pandoc-svgbob-filter`フィルタ

より高度なダイアグラムが描ける[svgbob][svgbob]のファイルをレンダリングするフィルタです。Python製です。
svgbobの*Linux用*バイナリが同時にインストールされます。

[svgbob]: https://github.com/ivanceras/svgbob

#### インストール {-}

```bash
pip3 install git+https://github.com/pandocker/pandoc-svgbob-filter.git
```

#### サンプルコード {-}

[](data/svgbob.bob){.listingtable #lst:svgbob-sample}

```markdown
[svgbob](data/svgbob.bob){.svgbob} 
```

[svgbob](data/svgbob.bob){.svgbob}

#### オプション一覧 {-}

これらのオプションは指定がなければデフォルト値が使われます。yamlメタデータに`svgbob`を加えると
こちらをオプション未指定時のデフォルト値として扱います。

| Filter option  | yaml metadata         | Description                                                               | default value |
|:---------------|:----------------------|:--------------------------------------------------------------------------|:-------------:|
| `font-family`  | `svgbob.font-family`  | Text will be rendered with this font                                      |    "Arial"    |
| `font-size`    | `svgbob.size`         | text will be rendered with this font size                                 |      14       |
| `scale`        | `svgbob.scale`        | scale the entire svg (dimensions, font size, stroke width) by this factor |       1       |
| `stroke-width` | `svgbob.stroke-width` | stroke width for all lines                                                |       2       |

#### フィルタ適用例 {-}

`-F`/`--filter`オプションに`pandoc-svgbob-inline`を与えるだけです。`pandoc-crossref`などと併用する場合は
このフィルタを先に記述します。

```bash
pandoc -F pandoc-svgbob-inline markdown.md -o html.html
pandoc -F pandoc-svgbob-inline -F pandoc-crossref markdown.md -o html.html
```

# 新たな沼にようこそ

Docxファイル（以下単にDocx）ないしMSWord（以下単にWord）と戦うのは本当に骨が折れます。
そもそも戦うとか言ってる時点で敵視が垣間見えますが、Wordが意味不明な挙動をするので仕方がありません。

## 環境構築タイム

インストーラ実行祭りです。

### WSL(Windows Subsystem for Linux)

Bash on Ubuntu on Windowsとして発表され、Windows10 1709版（Fall Creators Update）以降
で正式に導入されたLinuxシステムです。悪いことは言わないので可及的速やかに1803以上にアップグレードするべきです。

<https://docs.microsoft.com/ja-jp/windows/wsl/install-win10>をよく読んで導入してください。

導入後は`sudo apt update; sudo apt upgrade`で環境を新しくしておいてください。

こだわりがある人は日本のサーバを参照するように設定ファイルに手を加えてもいいと思います。

#### ディストリビューションはUbuntu16.04

WSLで導入できるディストリビューションは複数ありますが、Ubuntu16.04を対象にします。ほかの
ディストリは18.04もDebianも一切調べていません。

### マウントポイントの設定(wsl.conf)

`/etc/wsl.conf`を任意のエディタで開き編集します。

```bash
$ sudo nano /etc/wsl.conf
```

[](data/wsl.conf){.listingtable}

### Git (on WSL)

Gitをapt経由でインストールします。

```bash
$ sudo apt install git
```
これだけです。
こだわりがあれば自力で新しいバージョンを入れてもいいです。

### Docker (on WSL)

Windows用のDockerディストリビューションもありますが、今回は使いません。WSL上にインストールします。
アンインストールに問題を抱えていますが[^docker-uninstall-problem][^docker-uninstall-problem2]、困らないですよね？
こだわりがある人は新しいバージョンを入れてもいいですが、推奨はしません。

[^docker-uninstall-problem]: アンインストール時に実行されるスクリプト（動いてないデーモンを停止しようとする）がコケて全体が失敗に終わる。
[^docker-uninstall-problem2]: <https://stackoverflow.com/questions/51377291/cant-uninstall-docker-from-ubuntu-on-wsl/51939517>

```bash
$ sudo apt install docker.io
```

### IDE(PyCharm)

**Git(VCS)コミット時に外部ツールを起動する機能がついたバージョン**が必要です。今までにPyCharmをインストール
したことがないなら何も考えずに最新版(Community版・フリー版で十分です)を入れるべきです。2018年版なら
どのバージョンでもいいです。2017年版もいけるかもしれませんが未テストです。

#### Markdown用プラグイン

`Markdown Navigator`をインストールします。こちらもフリー版で事足ります。

## PandocのDocx対応状況を確認しよう

<!--この本はPandocを使うことを前提にしているので、PandocとDocx-->
何も考えずとりあえずDocxに出力するだけなら以下のコマンドでできます。

```bash
pandoc -t docx -o docx.docx markdown.md
```

出力ファイル`docx.docx`はデフォルトのスタイルを適用したものになります。デフォルトのスタイルが
どういうものかを確認するには
`pandoc --print-default-data-file reference.docx > template.docx`{.bash}で出力した`template.docx`
を参照します。このファイルを叩き台にして独自テンプレートにします([@sec:develop-template])。

# テンプレートのスタイルを決めよう {#sec:develop-template}

実はこの話題は別の方が研究中です。[参考書籍](#references)に列挙しておきます[^refer-doujinshi]。
内容を見てみると自分とほとんど同じことしてますね。この本の存在意義が薄れちゃいますね。

[^refer-doujinshi]: 参考書籍類は大半が同人誌です。狭い世界ですね。

## デフォルトテンプレートに採用されているスタイル

* Title / 表題
* Subtitle / 副題
* Author
* Date / 日付
* Abstract
* Heading 1〜9 / 見出し1〜9
* First Paragraph
* Body Text / 本文
    * Body Text Char
* Verbatim Char
* Hyperlink / ハイパーリンク
* 脚注参照
* 脚注文字列
* Block Text / ブロック
* Quote / 引用文
* Compact
* Definition
* Definition Term
* Figure
* Image Caption
* Table Caption
* Bullet List 1〜5 / 箇条書き 〜 箇条書き５

## 大方針：デフォルトから大きく変化させない

テンプレートファイルの変更は無制限に行うことができますが、それらの変更の継承具合（全て正しく
適用されて出力されるか）はわかりません。一方でデフォルトファイルのスタイルや情報は基本的に
継承されるということです。したがってデフォルト設定を大きく逸脱させないテンプレートにします。

### 英語のスタイル名を用意する

Pandocが出力したテンプレートファイルを日本語版Wordで開くと上部のスタイル一覧に日本語に翻訳された
スタイル名が並びます。Wordは"かしこいので"、自動的にスタイル名を翻訳してくれます。
しかし、内部ではWordによる**やんごとなきスタイルID変更**が行われてしまっています。
文字コード周辺の問題で、UTF8なスタイル名を見つけるとスタイルIDが適当なランダムっぽい値に変更されちゃうようです。
^[<https://github.com/jgm/pandoc/issues/5074#issuecomment-440938368>]
こういうとこやぞWord...

たとえば"`Bullet List 1`"は日本語で`箇条書き`が対応します。実際に画面ではそのような表示になります。
一方内部では`箇条書き`は"`aa`"のような適当なスタイルIDに割り当てられています。したがってテンプレート内で
`箇条書き`スタイルに変更を行いかつ原稿内で"`Bullet List 1`"を指定しても、
両者のスタイルIDが異なる、というか"`Bullet List 1`"スタイルはテンプレート内に存在しないので
Pandocで変換したファイルに"`箇条書き`"スタイルは適用されないのです。"`Body Text`"風の"`Bullet List 1`"
が突然現れ適用される形になります。

ただし、いくつかのデフォルトスタイルではスタイル名がリンクしていました
([@tbl:styles-correctly-converted])。

Table: 正しく相互変換されるスタイル名一覧 {#tbl:styles-correctly-converted}

| Style Name(EN) | Style Name(JP) |
|:---------------|:---------------|
| Title          | 表題            |
| Subtitle       | 副題            |
| Date           | 日付            |
| Body Text      | 本文            |
| Heading 1〜9   | 見出し1〜9      |

### ページサイズと余白

お好みでページサイズと余白を設定してください。筆者はB5で上下30ミリ・左右20ミリに設定しています。

### ヘッダ・フッタ

ヘッダまたはフッタにページ番号などを記載させるといいと思います。

### 番号つき見出しにする・番号なし見出しを追加する

Pandocはデフォルトで見出しに番号を振らず、`--number-sections`というオプションを追加することで
番号付けに対応します。PandocはDocx出力のときはこれを*無視*します。デフォルトのスタイルではオプション
が与えられているかどうかに関係なく番号なしになります。これはWordの仕様の問題で、番号つき・番号なしで
2種類のスタイルを予め用意しなければならないからだと思われます。

### レベル1見出しの前は改ページさせる・レベル2以降はさせない
### コードブロック用スタイルを追加する
### その他オレオレスタイルを用意する

- `Heading Unnumbered 1`
- `Heading Unnumbered 2`
- `Heading Unnumbered 3`
- `Heading Unnumbered 4`
- `Centered`

# 原稿を書こう（本題）
## 任意のスタイルを適用させるPandocコマンドを利用する

# 参考書籍 {- #references}

1. "2010-2016ユーザーに向けたWORDと文書のレイアウト - 文字の配置・段落設定から図・罫線表の利用まで-", 2017.12(C93), URT. Lab
2. "すべてのExcelドキュメントを生まれる前に消し去りたい本2018 v2.0.0(正式版)", 2018.10(技術書典５), 竜睛舍
3. "PyCharm のすすめ デプロイとデバッグ編 珍獣 著 2018-10-08 版", 2018.10（技術書典5）
4. "R MarkdownでWord文書を作ろう", 2018.11(初版２刷), niszet工房

# 更新履歴 {-}

## Revision4.0（C95） {-}

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}
