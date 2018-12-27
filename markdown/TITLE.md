\\newpage

\\newpage

\\toc

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
スクリーンショットを撮るのだけはWindowsマシンを使いました。

[^company-machine]: 筆者の会社支給のマシンはOS更新してもDockerとの相性問題が残るし突然の
シャットダウン現象が治らないしベンダーは遅延戦法で修理実行まで1ヶ月以上かかったしその割に
修理そのものは2時間しなかったしWindows嫌い

WSLがちゃんと動かないWindows機をお使いの方は、*手元でのコンパイルを諦めて*
外部CIサービスを利用してください。

この本は、`pandocker`の更新情報、新しいフィルタの紹介、初のWindowsユーザ向け環境構築ガイド、
テンプレート作成例、ローカルビルド実行までを取り扱います。

# `pandocker`はまた更新されました
## 全体的な更新事項
### `pandoc_misc`をpipでインストールできるようにした

`pandocker`フレームワークは`pandoc_misc`というgitリポジトリを`/var`直下に置いて、
Makefileなどの参照先にしています。このリポジトリにはPandocに与えるオプションや
TeX・HTML出力のためのテンプレートファイルが用意されています。これらは従来
`/var`に直接クローンしてくる必要がありましたが、pipでインストールできるようにしました。

この変更によって、初期ファイル一式をインストールする`pandoc-misc-init`スクリプトが用意され、
特に新規に文書リポジトリを作るときのセットアップが楽になりました。**ただし、あらかじめ
Dockerイメージ`k4zuki/pandocker`をpullする必要があります。**

##### インストール

```bash
pip3 install git+https://github.com/k4zuki/pandoc_misc.git@pandocker
docker pull k4zuki/pandocker
```

### アスキーアート系フィルタ`pandoc-svgbob-filter`を追加

より高度なダイアグラムが描ける[svgbob][svgbob]のファイルをレンダリングするフィルタです。Python製です。
svgbobの*Linux用*バイナリが同時にインストールされます。

[svgbob]: https://github.com/ivanceras/svgbob

##### インストール

```bash
pip3 install git+https://github.com/pandocker/pandoc-svgbob-filter.git
```

##### サンプルコード

[](data/svgbob.bob){.listingtable #lst:svgbob-sample}

```markdown
[svgbob](data/svgbob.bob){.svgbob} 
```

[svgbob](data/svgbob.bob){.svgbob}

##### オプション一覧

これらのオプションは指定がなければデフォルト値が使われます。yamlメタデータに`svgbob`を加えると
こちらをオプション未指定時のデフォルト値として扱います。

| Filter option  |     yaml metadata     |                                Description                                | default value |
|:--------------:|:---------------------:|:-------------------------------------------------------------------------:|:-------------:|
| `font-family`  | `svgbob.font-family`  |                   Text will be rendered with this font                    |    "Arial"    |
|  `font-size`   |     `svgbob.size`     |                 text will be rendered with this font size                 |      14       |
|    `scale`     |    `svgbob.scale`     | scale the entire svg (dimensions, font size, stroke width) by this factor |       1       |
| `stroke-width` | `svgbob.stroke-width` |                        stroke width for all lines                         |       2       |

\\newpage

##### フィルタ適用例

`-F`/`--filter`オプションに`pandoc-svgbob-inline`を与えるだけです。`pandoc-crossref`などと併用する場合は
このフィルタを先に記述します。

```bash
pandoc -F pandoc-svgbob-inline markdown.md -o html.html
pandoc -F pandoc-svgbob-inline -F pandoc-crossref markdown.md -o html.html
```

## LaTeX出力に関する更新事項
### コンフィグオプションを追加

次節とも関連しますが、LaTeX出力のレベル５ヘッダにナンバリングされる問題がずっと続いていましたが、
マニュアルに設定オプションがあることを発見しました^[<https://pandoc.org/MANUAL.html#variables-for-latex>]。

この中の`secnumdepth`を**3**にするとうまくいくことがわかったので、デフォルト値を
`pandoc_misc/config.yaml`に追記しました。このファイルはシステムデフォルト値を保存するために用意してあります。
この値は原稿リポジトリ内の`markdown/config.yaml`に追記することで上書きできると思います。

## DOCX出力に関する追加事項

Docxファイルの取扱は本当に面倒[^dont-think-anyone-oppose]ですが、少しでもマシな使い勝手になるように
Pandocフィルタとツールをいくつか作りました。

### Docx出力専用フィルタを追加 {-}

[^dont-think-anyone-oppose]: これは個人の感想ですが、あまり強固に反論する人もいないんではないかなって

### `pandoc-docx-pagebreakpy`フィルタ

`pandoc-docx-pagebreak`というHaskell製フィルタを参考にしています。Pythonで書かれています。

pagebreakの名の通り原稿内の`\\newpage`を改ページに変換します。おまけとして`\\toc`を目次に変換します。
`\\toc`はテンプレート内の`TOC Header`（`目次の見出し`）スタイルが適用されます。このフィルタと同時に
pandocに`--toc`オプションを与えると目次が*２回出現*するので注意してください。`\\newpage`ないし`\\toc`の
前後は必ず空行が必要です。

##### インストール

```bash
pip3 install git+https://github.com/pandocker/pandoc-docx-pagebreak-py
```

##### サンプルコード

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

##### フィルタ適用例

`-F`/`--filter`オプションに`pandoc-docx-pagebreakpy`を与えるだけです。

```bash
pandoc -t docx -F pandoc-docx-pagebreakpy markdown.md -o docx.docx
```

### `pandoc-docx-utils`フィルタ(1)

Docxを扱うときに微妙に使いづらく感じる点をちょっと改善するフィルタです。Pythonで書かれています。

今のところ２つの機能が実装されています([@sec:apply-style-to-images]、[@sec:unnumbered-headers])。
いずれの機能もテンプレート内に追加のスタイル定義を必要とします。テンプレート内で定義されていない場合も
各スタイルが適用されますが、それらは`Normal`（"標準"）スタイルを継承したものになります。

##### インストール

```bash
pip3 install git+https://github.com/pandocker/pandoc-docx-utils-py.git
```

#### 画像に任意のスタイルを適用する {#sec:apply-style-to-images}

##### 困り所

デフォルトのDocx出力では、段落中でない画像引用は必ず左寄せになってしまいます。

##### この機能の使い方

1. あらかじめテンプレートに画像引用時に使いたいスタイルを用意します。
1. Markdownの画像引用に`custom-style`オプションを追加し、用意したスタイル名を与えます[^with-other-filters]。
1. `custom-style`オプションを省略すると`Image Caption`スタイルを適用します。テンプレート内で
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

### `pandoc-docx-utils`フィルタ(2)
#### `unnumbered`指定されたヘッダに番号なしスタイルを適用する {#sec:unnumbered-headers}
##### 困りポイント

Pandocはデフォルトで見出しに番号を振らず、`--number-sections`というオプションを追加することで
対応します。このオプションを有効にしつつ例外的に番号なしにしたい場合は見出しに`{-}`もしくは
`{.unnumbered}`をつけることでフラグを立ててPandocに知らせます。PandocはDocx出力のときはこのルールを
**無視**します[^word-matter]。

[^word-matter]: これはWordの仕様の問題で、番号つき・番号なしで2種類のスタイルを予め用意しなければ
ならないからだと思われます。

##### この機能の使い方

1. あらかじめ`Heading Unnumbered 1`/`Heading Unnumbered 2`/`Heading Unnumbered 3`/`Heading Unnumbered 4`
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

##### フィルタ適用例

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

# 新たな沼にようこそ

Docxファイル（以下単にDocx）ないしMSWord（以下単にWord）と戦うのは本当に骨が折れます。
そもそも戦うとか言ってる時点で敵視が垣間見えますが、Wordが意味不明な挙動をするので仕方がありません。

## 環境構築タイム

インストーラ実行祭りするのも面倒なのでWSL一本で行きます。新規インストールが必要なのは
PyCharmくらいです。

### WSL(Windows Subsystem for Linux)

Bash on Ubuntu on Windowsとして発表され、Windows10 1709版（Fall Creators Update）以降
で正式に導入されたLinuxシステムです。1709だと制限事項が多いので悪いことは言わないので
可及的速やかに1803以上にアップグレードするべきです[^company-machine-upgraded]。

[^company-machine-upgraded]: 筆者の会社PCもアップグレード申請してようやく1803に
アップグレードされました。

<https://docs.microsoft.com/ja-jp/windows/wsl/install-win10>をよく読んで
Ubuntu 16.04を導入してください。導入後は`sudo apt update; sudo apt upgrade`で
環境を新しくしておいてください[^point-to-jp-server]。

[^point-to-jp-server]: こだわりがある人は日本のaptサーバを参照するように設定ファイルに手を加えてもいいと思います。

#### ディストリビューションはUbuntu 16.04

WSLで導入できるディストリビューションは複数ありますが、Ubuntu 16.04を対象にします。ほかの
ディストリは18.04もDebianも一切調べていません。でも、最近のUbuntu16.04のアップデートによって
16.04を対象にしていた主な根拠が崩れてしまったので、ここに書かれているやり方はDebian系ならばどれでも通じると思います。

### Git on WSL

Gitをapt経由でインストールします。

```bash
$ sudo apt install git
```
これだけです。
こだわりがあれば自力で新しいバージョンを入れてもいいです。

### pandockerリポジトリのクローン {#sec:clone-pandocker}

Windows用各種設定ファイルを入手するため、pandockerのリポジトリをクローンしてきます。
クローン先はCドライブ内のどこかにしてください。

```bash
$ git clone https://github.com/pandocker/pandocker.git
```

### マウントオプションの設定(wsl.conf)

[@sec:clone-pandocker]でクローンしたリポジトリから`wsl.conf`を`/etc`にコピーします。

```bash
$ sudo cp <path/to/pandocker>/wsl/wsl.conf /etc/
```

ファイルの内容は以下のようになっています：

[](data/wsl.conf){.listingtable}

この中で`root = /`は絶対必要なわけではありませんが、Cドライブを`/c`としてマウントさせるために加えてあります。
`options = "metadata,umask=22,fmask=111"`の行はマウントオプションを設定しています。この行が
ないとWSL上ですべてのファイルに実行権限がつけられてとても都合が悪いので、つけておいてください。
ただし、これらのオプションの意味が分かっている人は自分流に改造してもいいです。

### Docker on WSL

Windows用のDockerディストリビューションもありますが、今回は使いません。WSL上にインストールします。
12月半ばのアップデートでDockerが18系にアップグレードされてしまったので[^xenial-docker-18]、17系を
Docker本家からダウンロード・インストールします。

17系を使わなければならない理由については、詳細に書かれたブログがあります[^docker-18-bad-example]
ので参考にしてください。要約するとWindows10-1803の時点ではDockerのバージョン*17.09.1*で導入された
機能に対応していないので、`docker pull`がコケてしまいます。
対策としてこのブログでは*17.09.0*をインストールしています。これにならって以下のようにインストールします：

```bash
$ curl -O https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.09.0~ce-0~debian_amd64.deb
$ sudo apt install -y ./docker-ce_17.09.0~ce-0~debian_amd64.deb
# ダウンロード済みのdebパッケージであればaptでインストールできます。
```

これまで筆者が見つけた各ブログで先人たちは`sudo apt install docker.io`でサクッとインストールしてますが、
今後は上のやり方でないとうまくいかないということですね。

[^xenial-docker-18]: <https://launchpad.net/ubuntu/+source/docker.io>
[^docker-18-bad-example]: "どうしても Docker on Ubuntu 18.04 on WSL したかった" <https://qiita.com/guchio/items/3eb0818df44fdbab3d14>

### Docker daemonの自動起動を設定

(この節の内容は先人のブログで見つけたもの[^docker-daemon-blog]をちょっと焼き直したものです。)

[^docker-daemon-blog]: "WSLのdocker daemonを自動起動させる" <https://qiita.com/forest1/items/ab6d8b345653c614229b>

タスクスケジューラにDockerデーモンの自動起動タスクを追加します。スタートメニューで"task"を検索して
タスクスケジューラを起動します([@fig:start-task-scheduler])。

![Start Task Scheduler](images/start-task-scheduler.png){.rotate angle=-90 #fig:start-task-scheduler}

起動したら右側の"タスクのインポート"をクリックして[@sec:clone-pandocker]でクローンしたリポジトリから
"Docker.xml"を選択します。すぐに[@fig:change-username]の画面になるのでWindowsのユーザ名
を入力し"名前の確認"→"OK"をクリックして一旦インポートを完了します。

![Change Username](images/task-change-username.png){#fig:change-username}

インポートしたタスクを再度編集し、デーモン起動スクリプトのパスを変更します。

"操作"タブに移動し"編集"をクリック→"引数を追加"の内容を[@sec:clone-pandocker]の
リポジトリ内の`dockerstart.sh`へのパスに変更して"OK"→操作タブで"OK"して完了します([@fig:edit-task-script])。

![Edit Task](images/task-edit-script.png){#fig:edit-task-script}

これでPCを再起動すると、ログイン時にWSLターミナルが起動しrootパスワードを求められます(これは再起動のたびに求められます)。

### IDE(PyCharm)

**Git(VCS)コミット時に外部ツールを起動する機能がついたバージョン**が必要です。今までにPyCharmをインストール
したことがないなら何も考えずに最新版(Community版・フリー版で十分です)を入れるべきです。2018年版なら
どのバージョンでもいいです。2017年版もいけるかもしれませんが未テストです。

最新版はこちらからダウンロードできます：<https://www.jetbrains.com/pycharm/download/>

#### Markdown用プラグイン

`Markdown Navigator`[^markdown-navigator]をインストールします。筆者は有料版を使っていますがこちらもフリー版で事足ります。

[^markdown-navigator]: <https://github.com/vsch/idea-multimarkdown>

## Dockerイメージのダウンロード

ここまでの手順でDockerデーモンを手動起動してdockerイメージを動かすことができます。

WSLコンソールを管理者権限で開き普通に`docker pull`します。今回はwhalebrewは不要です。
後述するIDEのセットアップによって全部賄われます。

```bash
docker pull k4zuki/pandocker
```

# IDEをセットアップする

PyCharm IDEを例にしてプロジェクトの作り方と外部ツールの設定を説明します。Pythonの新規インストールは不要です。

## プロジェクトを作る
### 新規作成

とりあえず原稿ディレクトリの親ディレクトリを新規プロジェクトとして開きます([@fig:create-project])。

![Create Project](images/pycharm-project.png){#fig:create-project height=70mm}

### Content Root {#sec:register-content-root}

原稿ディレクトリを"Content Root"([@fig:content-root])としてPyCharmに登録します。
Settingsを開き、**Project Structure**サブメニューに行き、右上の**＋**で任意のディレクトリを登録します。
この図では2箇所が登録されています。**OK**をクリックして一旦画面を閉じます。

![Content Root](images/register-content-root.png){#fig:content-root height=70mm}

### VCS(Git)リポジトリ

原稿ディレクトリをgitリポジトリとしてPyCharmに認識させます([@fig:register-vcs])。
Settingsを再度開き、**Version Control**サブメニューに行き、グレーアウトされている**Unregistered roots**
から目的のディレクトリを選択し(①)、右上の**＋**で登録します(②)。**Apply**または**OK**をクリックして確定します(③)。

\\newpage

![VCS repository](images/register-vcs-repository.png){#fig:register-vcs height=60mm}

## External Toolsの登録

External Tools(外部ツール)が登録されていると上部メニューのToolsまたは右クリックメニュー
から実行可能になります。外部ツールはマクロの一種と考えることもできます。

pandockerを使ったHTML/PDF/DOCXへの出力と出力ディレクトリの削除(CLEAN)を外部ツールとして登録します。

Settingsを開き、**Tools** → **External Tools**に行き、新規作成のため**＋**をクリックします。
([@fig:external-tools-1])

![External tools](images/register-external-tools.png){#fig:external-tools-1 height=70mm}

[@fig:external-tools-edit]を参考にしてName(*HTML*)とGroup(*Pandocker*)に値を入れ、
[@tbl:external-tools-parameters]のように編集します。
Advanced Options(④〜⑦)は４つともチェックを入れます。

Table: External Tools parameters {#tbl:external-tools-parameters}

| Parameter            | Value                                                          |
|:---------------------|:---------------------------------------------------------------|
| ① Program           | `wsl.exe`                                                      |
| ② Arguments         | `docker run --rm -v /$PWD:/workdir k4zuki/pandocker make html` |
| ③ Working Directory | `$ContentRoot$`                                                |

![Edit External Tools](images/pycharm-external-tools-edit.png){#fig:external-tools-edit}

一つ作ればあとはコピーしてNameとArgumentsを変更すればすぐに作れます。

原稿を開いて右クリックメニューを出すと下の方にExternal Toolsサブメニューが現れ任意の
コマンドを実行できるようになっています。

### コミット時に自動実行させる

IDE上で原稿の変更をコミットするときに上記の外部ツールを自動実行させます。いわゆるコミットフックです。
まずコミットウィンドウを開きます([@fig:pycharm-git-commit])。右側の**After Commit**→**Run Tool**
から登録済の外部ツールを選択します。この図ではすでに"PDF"に設定されています。

![Git Commit](images/pycharm-git-commit.png){#fig:pycharm-git-commit}

# 原稿を書こう（本題）
## 任意のスタイルを適用させるPandocコマンドを利用する

<#include "appendix.md">

# 参考書籍 {- #references}

1. "2010-2016ユーザーに向けたWORDと文書のレイアウト - 文字の配置・段落設定から図・罫線表の利用まで-", 2017.12(C93), URT. Lab
2. "すべてのExcelドキュメントを生まれる前に消し去りたい本2018 v2.0.0(正式版)", 2018.10(技術書典５), 竜睛舍
3. "PyCharm のすすめ デプロイとデバッグ編 珍獣 著 2018-10-08 版", 2018.10（技術書典5）
4. "R MarkdownでWord文書を作ろう", 2018.11(初版２刷), niszet工房

# 更新履歴 {-}

## Revision4.0（C95） {-}

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}
