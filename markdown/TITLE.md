# まえがき {-}

```
 ________________
< Dockerはいいぞ >
 ----------------
    \\
     \\
      \\
                    ##        .
              ## ## ##       ==
           ## ## ## ##      ===
       /""""""""""""""""___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \______ o          __/
        \    \        __/
          \____\______/
```

このドキュメントは、技術書典3にて発表した「私的Markdown-PDF変換環境を紹介する本」の続編に
当たる本[^compiled-by-docker]です。~~前作の売れ行きが予想を上回って冬コミ在庫が心許ない事になったので
続編を書くことにしました~~前作の予告通りDockerイメージの構築とCircleCIによるGithubリリースの
自動更新までうまく行ったので、その報告です。

[^compiled-by-docker]: もちろんこの本もDockerイメージを使ってコンパイルされました。

#### 前回までの「私的Markdown-PDF変換環境を紹介する本」（海外ドラマ風紹介文） {-}
前作では、_Unix環境を対象に_ 筆者が構築したPandoc式PDFドキュメント制作環境とその機能について、
最初のパッケージマネージャ導入から解説しました。Python/NodeJS/Haskell/LaTeXをインストールし、
PandocおよびPandocフィルタをインストールし、その他便利コマンドをインストールし、やっと書き出すところまで、
骨の折れる、読者のマシン環境を汚しかねない導入でした。

#### 反省事項？と改善事項と制限事項 {-}
前作を書き上げてからもWindows環境を無視するのはいかがなものかという心の葛藤[^windows-lol]が
ありました。これはやっぱりOS依存性が低いやり方[^os-independent]としてDockerイメージ
を公開して使ってもらえばいいんじゃないかと。さらにCIシステムの構築例を挙げておけば、
Windowsでも使えるだろう、ということで、CircleCIを使ってみました[^why-not-travis]。

[^why-not-travis]: この手のCIといえばTravisなのですがDockerを使うのが簡単なのか
よくわからなかったのでこっちにしました

ところで、WindowsでDocker導入って使えるんだろうかと思って実際に会社の**Windows7PC**での導入実験を行ったところ、
やっぱり環境依存があるっぽいです[^windows-hell]。残念ですがWindowsユーザさんは
**Fall Creators Update(2017)を適用したWindow10PC**を使って下さい。WSLは不要というかちゃんと動かないらしいので
対象外です。

**と思ったのですが筆者のDocker for Windows環境ではどーーーーーしてもホストのドライブがマウントできず実験が
続行できませんでした。ということDockerの使用についてWindowsは対象外にします。**
LinuxはもとよりMacもローカルでDockerを動かすのは簡単でした[^unix-env]。

[^windows-lol]: Windowsとかずっとオープンβ()だし無視しようよ（悪魔~~天使~~）
vs.
一応会社でも使えるしやっといたほうがいいですよ（天使~~悪魔~~）
[^os-independent]: JAVA（笑）か？
[^windows-hell]: 自分のマシンはNGでラボのマシンはOKだったのでリモートで動かしてる。Windowsきらい。
[^unix-env]: 筆者が確認したOSはUbuntu16.04LTS/MacOS Sierraです。

# 前作からの`pandoc_misc`改良点
## HTML出力：等幅フォントの第一候補をSource Code Proに変更
とくにMacで思った通りのフォントになっていなかったので、最近流行りのSourceCodeProを最初に探すように
CSSを更新しました。最終的に`monospaced`を指すのは変わらないので問題はないと思います。

## PDF出力：TeXライブラリを追加
### すこしだけ自由度のあるTeX使用
PandocパーサはMarkdown内にインラインTeXがあってもある程度処理してくれます[^inline-tex]が、`\\begin{package}`
や`\\end{package}`が使えずにいました。この点を若干改善するようにTeXテンプレートを更新し、
`\\Begin{package}`と`\\End{package}`に挟まれたMarkdown記述には`package`というTeXパッケージの
効果が適用されるようになります。
どうやらこの改良でも`\\Begin{package}[options]`はうまくいかないようです。当面はオプションがつかない
TeXパッケージ（かつTeXテンプレートに採用されているもの）のみの対応になります。

以下のようなパッケージが適用できます。

- tcolorbox
    - 文章の周りに枠がつきます。文章の長さがページ幅を超える場合は詰め込みを試みるようです。
    - 枠内の文章がページをまたがると切り落とされてしまいます。
- tikz
    - すごい図形描画パッケージらしいです。
- mdframed（tikzつき）
    - tcolorbox同様に文章の周りに枠がつきます。文章の長さがページ幅を超える場合は
    自動的に改行されます。
    - オプションを与えるとよりかっこいい枠が作れるらしいです。が、オプションがつけられないので
    デフォルトの地味な細い線枠になってしまいます。
    - 枠内の文章がページをまたがっても大丈夫です

[^inline-tex]: すくなくとも`\\newpage`は効きます。どうやら括弧がつかないコマンドなら
いけるんではないかなと

## ページを横長にする（ランドスケープ）
PDF出力のときに横長の表を引用するのが楽になりました。実現のためにTeXテンプレートに手を入れています。
`\\Startlandscape`と`\\Stoplandscape`の間の区間は横長ページになります。

- TeXで１ページだけ余白設定を変更する方法 by \@genyajoe on \@Qiita
    - <https://qiita.com/genyajoe/items/4ca0652587651593d502>

`````markdown
\\Startlandscape
```table
---
caption: 'SSCI_SPI_LCD BOM テーブル（抜粋）'
include: "data/SSCI_SPI_LCD.csv"
width: 1.0
---
```
\\Stoplandscape
`````

\\Startlandscape
```table
---
caption: 'SSCI_SPI_LCD BOM テーブル（抜粋）'
include: "data/SSCI_SPI_LCD.csv"
table-width: 1.0
---
```
\\Stoplandscape

## ソースコード引用フィルタ"ListingTable.py"を拡張
前作で紹介したソースコード引用フィルタですが、インライン表記版を追加しました。
画像ではなく普通のハイパーリンク表記を使います。頭に`!`がつかない方です。
この表記をするときは前後に空行を追加し、同じ行にリンク以外何もない状態にする必要があります。
さらに、範囲引用することもできるようになりました。引用元ファイルの`from`行目から
`to`行目を引用します。`from=5`、`to=12`のとき５行目から１２行目を引用します。
引用された部分の最後が空行だった場合は、HTML出力ではそのままですが、PDF出力ではTeXによって詰められてしまいます。
また、classを廃止しtypeに統一するなどオプションの統廃合を行いました。

~ところで、すでにHaskell製の同様のフィルタがあるようです。~

```table
---
caption: ListingTableフィルタオプション改
markdown: True
alignment: DCCD
width:
  - 0.15
  - 0.15
  - 0.15
  - 0.55
---
オプション,省略可能,デフォルト値,意味
`source`^[ブロック表記のとき。インライン表記ではURL部で指定する],N,,ソースファイル名(フルパス)
~~class~~**廃止**,~~N~~,,"~~ソースファイル種類(python,cpp,markdown etc.)~~ `type`で統一"
`type`,Y,plain,"ソースファイル種類(python,cpp,markdown etc.)"
~~tex~~**廃止**,~~Y~~,~~False~~,~~LaTeXを出力するとき"True"にする。case sensitive~~
`from`,Y,1,引用元ソースの切り出し開始行
`to`,Y,max,引用元ソースの切り出し終了行
```

`````markdown
前の文章

[Sample inline listingtable](README.md){.listingtable type=markdown from=5 to=12 #lst:inline-listingtable-sample}

次の文章
`````
前の文章

[Sample inline listingtable](README.md){.listingtable type=markdown from=5 to=12 #lst:inline-listingtable-sample}

次の文章

## リポジトリにタグを打つようにした
`pandoc_misc`の環境はgitによる管理はあっても今まで自分の自分による自分のためのものだったので、
内容は結構適当でした。`pandocker`のビルド時に`pandoc_misc`リポジトリの特定タグを参照するように
Dockerfileを編集し、更新があるたびに書き換えるようにしています。

# Dockerイメージを使ってHTML/PDFを出力する（本編）
## _pandocker-\\*_ Dockerイメージ

とりあえず動くようになったDockerイメージ「`pandocker`」の解説をしていきます。

### ベースイメージ選定の歴史：Alpine→Ubuntu→Alpine
#### ニコイチ作戦です！（Alpine） {-}

どうやらAlpine LinuxっていうBusyBoxベースの軽量イメージを改造して使うのが最近の流行らしいんですよね。
たしかに組み込みで権威のある（？）Busybox系なら軽量です。Pandocフィルタが動作する環境は
PythonやらNodeJSやらについては新しめのバージョン（Python3.5+/NodeJS4系LTS）なら
いけるようなので、めんどくさいTeXと発表したばっかのPandoc2.0をどうにかすればいいという
目論見でした。それは概ねうまく行っていて、先達の成果をニコイチしてそれなりのところまで
構築したんですが、そのときはxelatexがglibc付近でコアダンプしてうまく動かずPDFを作れないので
一旦実験を中断しました。

ニコイチ作戦で参考になったAlpineベースのイメージ：

- skyzyx/alpine-pandoc
    - https://github.com/skyzyx/alpine-pandoc
    - https://hub.docker.com/r/skyzyx/alpine-pandoc/
- paperist/alpine-texlive-ja
    - https://github.com/Paperist/docker-alpine-texlive-ja
    - https://hub.docker.com/r/paperist/alpine-texlive-ja/

#### 近距離からの確実な撃破を目指しましょう（Ubuntu） {-}

とりあえず動くものを作っておいて入れ替える作戦に切り替えて、実績のあるUbuntu16.04ベースで安直に
構築したものが`pandocker`というわけです。実際は共通部分の`pandocker-base`と
リポジトリ追いかけ部分の`pandocker`に分かれています。
以下にDocker Hubのアドレスを置いておきます。

- pandocker/pandocker-base
    - https://github.com/pandocker/pandocker-base
    - https://hub.docker.com/r/k4zuki/pandocker-base
- pandocker/pandocker:
    - https://github.com/pandocker/pandocker
    - https://hub.docker.com/r/k4zuki/pandocker

安直ビルドなのでイメージサイズが重めです。圧縮されたときでも**737 MB** だそうです。
ローカルに展開すると2GB程度です。安直でも動くのでAppendixにDockerfile全文を引用しておきます。

#### もっとニコイチ作戦です！（Alpine） {-}

pandockerが安定してきたのでAlpineベースのイメージを作る検討を再開しました。
Alpine Linuxも今時のディストリなのでUbuntuでいうaptのような仕組み"APK"を持っています。
OSの開発版と安定版とでパッケージ群を分けるのも同様です。LaTeX系のapkパッケージは開発版に
しか用意されていない/次期安定版から用意される？のでそこから入手することを考えます。
この方法でTeXLiveを入れているイメージが見つかったので参考にしました。

- mattmahn/latex
    - https://github.com/mattmahn/docker-latex
    - https://hub.docker.com/r/mattmahn/latex/~/dockerfile

参考にしたDockerfileではベースイメージをAlpine:latest（現在はlatest=3.6）にしてありますが、
latestが指すバージョンは更新されていきます。意図しないバージョンのイメージを
使われたくないので`pandocker-alpine`は初めから3.6を指定してあります。
また、このイメージでは`texlive-full`で全`texlive-*`パッケージを一気に入れていますが、
`pandocker-alpine`は（とりあえず）`texlive-xetex`パッケージのみをインストールしました。

`pandocker-alpine`は現在も継続して実験中です。ほぼできあがっています。
圧縮時460MBで優秀です。ただ、重要なPandocフィルタ`pandoc-crossref`が動かなくて
メイン交代には至っていません。当面は`pandocker`(安直Ubuntuベース)を使ってください。

## pandockerをローカルで使う
### インストールする
Dockerの入手・導入は容易です。

- dmg: https://www.docker.com/docker-mac
- deb: https://www.docker.com/docker-ubuntu

ちゃんと動くようにしたあと、イメージをダウンロードしてきます。
```sh
docker pull k4zuki/pandocker
```
これでもう動くと思います。以下のコマンドでシェルが出てくればOKです。
```sh
docker run --rm -it k4zuki/pandocker
```

### 原稿リポジトリを作る

前作と同様に `$HOME/workspace/Mybook` を例に説明していきます。最初にディレクトリを作成しそこに移動します。
```sh
mkdir -p ~/workspace/Mybook
cd ~/workspace/Mybook
```

ここで次のコマンドを入れると一式がインストールされます。
```sh
docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make -f /var/pandoc_misc/Makefile init
```

原稿リポジトリのディレクトリ構造は前作でも説明しましたが、以下のようになっています。
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
gitリポジトリとして初期化します。
```sh
$ git init
$ git add .
$ git commit -m"initial commit"
```

この時点で`docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make`とするとコンパイルが走ります。

### 原稿を書く
前作と同様に書いていきます。pandoc_miscの改善点は順次pandockerに反映されていきますので、
定期的に`docker pull k4zuki/pandocker`するといいかもしれません。バグっぽいものはgithubで報告してください。

### 出力する

- HTML出力：`docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make`
- PDF出力：`docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make pdf`
- 成果物を消す：`docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make clean`

# CIサービスを使う
## プロバイダ選定：TravisCI vs. CircleCI
この本の原稿リポジトリではCircleCIを採用していますが、同じことができるならTravisCIのほうが
情報が多くていいかもしれません。
CIでやるべきことは

1. Dockerイメージをpullして起動する
1. リポジトリをチェックアウトする（クローンする）
1. HTML/PDFをコンパイルする
1. 成果物をGitHubリリースページにアップロードする

の４点です。成果物のアップロードはWebなAPI[^github-release-api]を使えばできるようですが、
やり方がさっぱりわからないのでghr[^github-release]というGolang系のプロジェクトの成果を使っています。

[^github-release-api]: https://developer.github.com/v3/repos/releases/#create-a-release
[^github-release]: https://github.com/tcnksm/ghr

# Appendix
### Dockerfile {-}
\\newpage
\\Startlandscape

[`pandocker-base`のDockerfile](pandocker-base/Dockerfile){.listingtable type=dockerfile}

[`pandocker`のDockerfile](pandocker/Dockerfile){.listingtable type=dockerfile}

[`pandocker-alpine`のDockerfile](pandocker-alpine/Dockerfile){.listingtable type=dockerfile}

\\Stoplandscape

### CircleCI {-}

[.circleci/config.yml](.circleci/config.yml){.listingtable type=yaml}

# 更新履歴 {-}
## Revision1.0（C93） {-}

- 前作の技術書典３での売れ行きは衝撃だった。75％は記録的（注：総部数20）
- 次は自作python製PandocフィルタをPyPiに登録する and/or CIビルドの構築かな。CircleCIが候補に挙がってる
- 最終目標はmarkdownを書いてコミットしてプッシュすると
    1. CIされて [X]
    1. HTML／PDFがGitHubのリリースページに置かれる [ ]
というところまでです。きっと誰かすでに実現してるしそうでなくても参考情報はいっぱいあるので助かってます:)
- Windowsｪ...
