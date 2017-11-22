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

このドキュメントは、技術書典3にて発表した「私的Markdown-PDF変換環境を紹介する本」の続編に当たる本です。
~~前作の売れ行きが予想を上回って冬コミ在庫が心許ない事になったので続編を書くことにしました~~
前作の予告通りDockerイメージを構築するところまでうまく行ったので、その報告です。

もちろんこの本もDockerイメージを使ってコンパイルされました。

#### 前回までの「私的Markdown-PDF変換環境を紹介する本」（海外ドラマ風紹介文） {-}
前作では、_Unix環境を対象に_ 筆者が構築したPandoc式PDFドキュメント制作環境とその機能について、
最初のパッケージマネージャ導入から解説しました。Python/NodeJS/Haskell/LaTeXをインストールし、
PandocおよびPandocフィルタをインストールし、その他便利コマンドをインストールし、やっと書き出すところまで、
骨の折れる、読者のマシン環境を汚しかねない導入でした。

#### 反省事項？と改善事項と制限事項 {-}
前作を書き上げてからもWindows環境を無視するのはいかがなものかという心の葛藤[^windows-lol]が
ありました。これはやっぱりOS依存性が低いやり方[^os-independent]としてDockerイメージ
を公開して使ってもらえばいいんじゃないかと。

しかしWindowsでDocker導入ってこれもまたどうかと思って実際に会社の**Windows7PC**での導入実験を行ったところ、
やっぱり環境依存があるっぽいです[^windows-hell]。残念ですがWindowsユーザさんは
**Fall Creators Update(2017)を適用したWindow10PC**を使って下さい。WSLは不要というかちゃんと動かないらしいので
対象外です。

**と思ったのですが筆者のDocker for Windows環境ではどーーーーーしてもホストのドライブがマウントできず実験が
続行できませんでした。ということで本作でもWindowsは対象外にします。Windows10ユーザさんは前作の内容に則って
WSL上のUbuntuを使ってください。**あるいは今後筆者がCIビルド環境を起こすまでお待ち下さい。
C93は無理っぽいから技術書典４とかでお会いしましょう。

Linux/Macユーザさんは前作での実績もあるし問題はほぼないものと思います。

筆者が確認したOSはUbuntu16.04LTS/MacOS Sierraです。

[^windows-lol]: Windowsとかずっとオープンβ()だし無視しようよ（悪魔~~天使~~）
vs.
一応会社でも使えるしやっといたほうがいいですよ（天使~~悪魔~~）
[^os-independent]: JAVA（笑）か？
[^windows-hell]: 自分のマシンはNGでラボのマシンはOKだったのでリモートで動かしてる。Windowsきらい。

# 前作からの`pandoc_misc`改良点
## 等幅フォントの第一候補をSource Code Proに変更
とくにMacで思った通りのフォントになっていなかったので、最近流行りのSourceCodeProを最初に探すように
CSSを更新しました。最終的に`monospaced`を指すのは変わらないので問題はないと思います。

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

## ソースコード引用フィルタを拡張
前作で紹介したソースコード引用フィルタですが、インライン表記版を追加しました。
画像ではなく普通のハイパーリンク表記を使います。頭に`!`がつかない方です。
この表記をするときは前後に空行を追加し、同じ行にリンク以外何もない状態にする必要があります。
さらに、ソースコードの一部を引用することもできるようになりました。引用元ファイルの`from`行目から
`to`行目を引用します。`from=5`、`to=12`のとき５行目から１２行目を引用します。引用された部分の最後の空行は、
HTML出力ではそのままですが、PDF出力ではTeXによって詰められてしまいます。
また、classを廃止しtypeに統一するなどオプションの統廃合を行いました。

```table
---
caption: ListingTableフィルタオプション改
markdown: True
alignment: DCCD
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
`pandoc_misc`の環境はgitによる管理はあっても今まで自分の自分による自分のためのものだったので、内容は結構適当でした。

# Dockerイメージを使ってHTML/PDFを出力する（本編）
## _pandocker_ Dockerイメージ
とりあえず動くようになったDockerイメージ「`pandocker`」の解説をしていきます。

### ベースイメージの選定：Alpine vs. Ubuntu
どうやらAlpine LinuxっていうBusyBoxベースの軽量イメージを改造して使うのが最近の流行らしいんですよね。
たしかに組み込みで権威のある（？）Busybox系なら軽量です。Pandocフィルタが動作する環境はPythonやらNodeJSやらは新しめの
バージョン（Python3.5+/NodeJS4系LTS）ならいけるようなので、めんどくさいTeXと発表したばっかのPandoc2.0を
どうにかすればいいという目論見でした。それは概ねうまく行っていて、先達の成果をニコイチしてそれなりのところまで
構築した[^pandocker-alpine]んですが、xelatexがglibc付近でコアダンプしてうまく動かずPDFを作れないので
実験を中断しました[^base-images]。いちおうDockerfileをAppendixに足しておきます。

[^base-images]: 先達の名誉のために付け足しておくと、_`platex`は動きます_。
platex系で構わないひとは叩き台にしてもいいと思います。

参考になったAlpineベースのイメージ：

- skyzyx/alpine-pandoc
    - https://github.com/skyzyx/alpine-pandoc
    - https://hub.docker.com/r/skyzyx/alpine-pandoc/
- paperist/alpine-texlive-ja
    - https://github.com/Paperist/docker-alpine-texlive-ja
    - https://hub.docker.com/r/paperist/alpine-texlive-ja/

とりあえず動くものを作っておいて入れ替える作戦に切り替えて、実績のあるUbuntu16.04ベースで安直に
構築したものが`pandocker`というわけです。実際は共通部分の`pandocker-base`とリポジトリ追いかけ部分の`pandocker`に
分かれています。以下にDocker Hubのアドレスを置いておきます。

- pandocker/pandocker-base
    - https://github.com/pandocker/pandocker-base
- pandocker/pandocker:
    - https://github.com/pandocker/pandocker

安直ビルドなのでイメージサイズが重めです。**737 MB** だそうです。

[^pandocker-alpine]: https://github.com/K4zuki/pandocker-alpine ほとんどメンテされてません

## pandockerを使う
### インストールする
Dockerの入手・導入は容易です。

- dmg: https://www.docker.com/docker-mac
- deb: https://www.docker.com/docker-ubuntu

ちゃんと動くようにしたあと、イメージをダウンロードしてきます。
```sh
docker pull pandocker/pandocker
```

### 原稿リポジトリを作る
### 原稿を書く
### 出力する
# Appendix {-}
### Dockerfile {-}
\\newpage
\\Startlandscape

[`pandocker-base`のDockerfile](pandocker-base/Dockerfile){.listingtable type=dockerfile}

[`pandocker`のDockerfile](pandocker/Dockerfile){.listingtable type=dockerfile}

\\Stoplandscape

### CircleCI {-}

[.circleci/config.yml](.circleci/config.yml){.listingtable type=yaml}

# 更新履歴 {-}
## Revision1.0（C93）

- 前作の技術書典３での売れ行きは衝撃だった。75％は記録的（注：総部数20）
- 次は自作python製PandocフィルタをPyPiに登録する and/or CIビルドの構築かな。CircleCIが候補に挙がってる
- 最終目標はmarkdownを書いてコミットしてプッシュすると
    1. CIされて [X]
    1. HTML／PDFがGitHubのリリースページに置かれる [ ]
というところまでです。きっと誰かすでに実現してるしそうでなくても参考情報はいっぱいあるので助かってます:)
- Windowsｪ...
