# 付録：秘伝のテンプレートを熟成する章 {#sec:develop-template}

実はこの話題は別の方が研究中です。[参考書籍](#references)に列挙しておきます[^refer-doujinshi]。
内容を見てみると自分とほとんど同じことしてますね。この本の存在意義が薄れちゃいますね。

[^refer-doujinshi]: 参考書籍類は大半が同人誌です。狭い世界ですね。

## PandocのDocx対応状況を確認しよう

<!--この本はPandocを使うことを前提にしているので、PandocとDocx-->
何も考えずとりあえずDocxに出力するだけなら以下のコマンドでできます。

```bash
pandoc -t docx -o docx.docx markdown.md
```

出力ファイル`docx.docx`はデフォルトのスタイルを適用したものになります。デフォルトのスタイルが
どういうものかを確認するには

```bash
pandoc --print-default-data-file reference.docx > template.docx
```

で出力した`template.docx`を参照します。このファイルを叩き台にして独自テンプレートにします([@sec:develop-template])。

## デフォルトテンプレートに採用されているスタイル {#sec:default-styles}

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
文字コード周辺の問題で、UTF8なスタイル名を見つけるとスタイルIDが適当なランダムっぽい値に
変更されちゃうようです^[<https://github.com/jgm/pandoc/issues/5074#issuecomment-440938368>]。
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
| Heading 1〜9   | 見出し 1〜9     |

### その他諸々...は他誌に譲ります

- ページサイズの設定
- 余白の設定
- ヘッダ・フッタの設定
- 見出しに連番をつける・つけない
- 見出し１の前に改ページ

これらの設定方法は主に参考書籍(2)に書かれていることを踏襲します。

### 秘伝のテンプレートないの？

*pandocker*の組み込み用に簡単なものは用意してあります。GitHub[^pandoc-misc-repository]
から**pythonize**ブランチをクローンするか、リポジトリをZipでダウンロード・解凍しブランチを切り替えて
入手してください。

```bash
git clone -b pythonize https://github.com/K4zuki/pandoc_misc.git
```

[^pandoc-misc-repository]: <https://github.com/K4zuki/pandoc_misc/tree/pythonize>
