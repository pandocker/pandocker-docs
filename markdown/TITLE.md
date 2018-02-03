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
_Dockerがちゃんと動けば_ Windowsでも簡単確実に動くようになったので、本当に
Dockerには感謝しています。もうGtk+まわりで悩まなくていいんだよ…[^company-machine]

[^company-machine]: 会社で支給されてるマシンはOSごと入れ直さないと動かないっぽいけど

この本の内容で楽しんでもらうために読者さんに最低限済ませてほしいことはたぶん
Gitのインストールを済ませておくことだけです。GitHubアカウントがあると楽ですが
必要というわけでもないです。

# 使ってみる編
## Dockerのインストール {-}
Dockerの入手・導入は容易です。

- `dmg`(for Mac): https://www.docker.com/docker-mac
- `deb`(for Ubuntu/Debian): https://www.docker.com/docker-ubuntu
- installer (for Windows 10): https://www.docker.com/docker-windows

## Dockerイメージのダウンロード {-}
シェル上で`docker pull k4zuki/pandocker`を打ち込む。これだけです。

## で、何ができるん？何をするん？

- Pandocというドキュメント変換プログラムをコアにして、
- 各種プラグインの活躍により、
- Pandoc Flavored Markdownで書かれた原稿を、
- それなりに体裁が整った{PDFまたはHTML}に出力します。

出力にあたって必要なコマンドは主に

- `pandocker make init`
- `pandocker make html`あるいは`pandocker make`
- `pandocker make pdf`
- `pandocker make clean`

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
`pandocker make init`の出番です。
```sh
$ pandocker make init PREFIX=~/workspace/MyBook
```
初期状態では以下のようなディレクトリ構成のはずです。
```
~/workspace/MyBook
|-- Makefile
|-- Out/
|-- images/
|-- markdown/
|   |-- TITLE.md
|   `-- config.yaml
`-- data/
    |-- bitfields/
    |-- bitfield16/
    `-- waves/
```

## 原稿リポジトリをコンパイル
ここでいったんコンパイルできるかどうか試してみましょう。`TITLE.md`の中身が空でも
コンパイルすることはできます。コンパイルする前に`Makefile`/`config.yaml`と
原稿一式をリポジトリに登録して最初のコミットをします。
```sh
$ git add .
$ git commit -m"initial commit"
```
この状態で`pandocker make html`とすると`Out/TARGET.html`というファイルができあがるはずです。
以下にコマンドの一覧を載せます。

`````table
---
caption: コンパイル方法
markdown: True
---
コマンド,効果,成果物
`pandocker make init`,ディレクトリ初期化,
`pandocker make html`,HTMLファイル生成,`$(TARGETDIR)/$(TARGET).html`
`pandocker make pdf`,PDFファイル生成,`$(TARGETDIR)/$(TARGET).pdf`
`pandocker make clean`,成果物を全部消去,"`rm -rf $(TARGETDIR)/*`  \
`rm -rf $(IMAGEDIR)/$(WAVEDIR)/`  \
`rm -rf $(IMAGEDIR)/$(BITDIR)/`  \
`rm -rf $(IMAGEDIR)/$(BIT16DIR)/`"
`````

`make pdf` を使うとXeLaTeXを使ってPDFに出力します。表紙、目次、本文、奥付けが体裁されたPDFができあがるはずです。

## 原稿リポジトリの調整
原稿のファイル名・置き場所・ディレクトリ構成は自由に配置してください。日本語ファイル名は
問題ないと思います^[推奨しません]が、スペースを入れるのは避けるべきです。

#### ファイル名・ディレクトリ名の設定(Makefile) {.unnumbered}
タイトルファイル名、ディレクトリ名を変更した場合は、そのことをビルドスクリプトに知らせる必要があります。
ビルドスクリプトはタイトルページのファイル名と各種ディレクトリ名をMakefileから取得します。
ディレクトリ名はすべてMakefileが置かれたディレクトリからの相対パスです。

```table
---
caption: Makeコンパイルオプション
width:
  - 0.15
  - 0.2
  - 0.50
  - 0.15
header: True
markdown: True
---
変数名,種類,意味,初期値
`CONFIG`,ファイル,pandocのコンフィグファイル,`config.yaml`
`INPUT`,ファイル,タイトルファイル,`TITLE.md`
`TARGET`,ファイル,出力ファイル,`TARGET`
`MDDIR`,ディレクトリ,タイトルファイルの置き場所,`markdown/`
`DATADIR`,ディレクトリ,データディレクトリ,`data/`
`TARGETDIR`,ディレクトリ,出力先ディレクトリ,`Out/`
`IMAGEDIR`,ディレクトリ,画像ファイルの置き場所,`images/`
`WAVEDIR`,ディレクトリ,WaveDromファイルの置き場所,`waves/`
`BITDIR`,ディレクトリ,8ビット幅Bitfieldファイルの置き場所,`bitfields/`
`BIT16DIR`,ディレクトリ,16ビット幅Bitfieldファイルの置き場所,`bitfield16/`
```

\\newpage
#### Pandocオプションの設定(config.yaml) {.unnumbered}
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
この状態で`make html`とすると`Out/TARGET.html`というファイルができあがるはずです。
以下に代表的なコマンドの一覧を載せます。

## 原稿を書く {#sec:pandoc}
これでとりあえずコンパイルが通るようになったので、実際の原稿を書けるようになりました。
**~~デファクトスタンダードこと~~**Pandoc式Markdown記法に則って書いていきます。

### ヘッダの書き方
デフォルトの`config.yaml`では章番号がつく設定で、例外的に消すこともできます。
例外が適用できるのは深さ４までの章番号に限られ、深さ５より深いものは _強制的に_ ナンバリングされます。
_**バグっぽいんだけどどうなんですかね**_。そこまで深く章分けする人あまりいないんですかね。

\\newpage
```markdown
# 深さ1：章番号なし {.unnumbered}
## 深さ2：章番号なし {.unnumbered}
### 深さ3：章番号なし {.unnumbered}
#### 深さ4：章番号なし {.unnumbered}
##### 深さ5+：章番号復活 {.unnumbered}
```

# 構築してみる編
## なにもないところからaptかbrewで構築する修行の章
## Docker楽チンヤッターの章
