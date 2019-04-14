\\newpage

\\newpage

\\toc

# まえがき {-}

このドキュメントは、コミケ９５にて発表した「私的Markdown-PDF変換環境を紹介する本４」の内容を
補完し、秘伝のWordドキュメントテンプレートを構築するガイドです。

## 前提環境 {-}

この本では、Word2010以降が動作するWindows10機[^company-machine]、またはMacを
対象環境にします。Windows10のOSバージョンは1803以降を前提にします。前作の手順に従い
環境を構築してあるものとします。

[^company-machine]: 筆者の会社支給のマシンは**いつの間にかKSﾍﾟﾙｽｷｰの設定が変更されて
HTTPが遮断されWSL上のaptが効かなくなってて本当にどうしようもなくなりました**。

今更いうほどでもないですがこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。
原稿とテンプレートDocxファイルの編集、フィルタの動作確認はMacで行われました。
スクリーンショットを撮るのだけはWindowsマシンを使いました。[^pdf-print]

[^pdf-print]: 実用に堪えないので印刷はPDF出力を使用しました。

WSLがちゃんと動かないWindows機をお使いの方は、*手元でのコンパイルを諦めて*
外部CIサービスを利用してください。KSﾍﾟﾙｽｷｰは即時削除してください。

この本は、恒例のpandocker環境の更新情報と、テンプレートファイル作成のヒント集で
構成されています。

# 今回の更新情報は？！

## Pandocが~~2.6~~ ~~2.7~~ **2.7.1**になったよ！

まずは上流プログラムの更新情報です。Pandoc本家がバージョン2.6、2.7及び2.7.1をリリースしました。[^pandoc-2.6][^pandoc-2.7][^pandoc-2.7.1]
更新内容はいろいろありますが、個人的に大事なのはPandoc式Markdown書式にタスクリストが
追加されたこと（\\@2.6）です[^pandoc-issue-3051]。
多くの出力で何らかの形で対応していて、Docxでは箇条書きの黒丸の直後に四角か四角にチェック(X)が入った
文字が置かれます。PDF出力では黒丸の代わりに四角・チェック入り四角が使われます。

もうひとつはコミケ95直前に遭遇して困った末にレポートした最高に意味わからんバグの修正です（\\@2.6）。
どうやら上流ライブラリのバグだったようで、pandoc側では解析のためにスタックダンプまで
行われていました[^pandoc-issue-5177]。

[^pandoc-2.6]: <https://github.com/jgm/pandoc/releases/tag/2.6>
[^pandoc-2.7]: <https://github.com/jgm/pandoc/releases/tag/2.7>
[^pandoc-2.7.1]: <https://github.com/jgm/pandoc/releases/tag/2.7.1>
[^pandoc-issue-3051]: <https://github.com/jgm/pandoc/issues/3051>
[^pandoc-issue-5177]: <https://github.com/jgm/pandoc/issues/5177>

## python-docxが0.8.10になったよ！

*pandocker*内で後処理に使っているpython-docxのバージョンが上がったんですが、筆者を含む数名が
インストール不能状態になりました[^python-docx-issue-594]。結果的に`setuptools`のバージョンが古すぎたせいでした。
読者の中でpython-docxの更新に失敗したひとがいれば、まず`setuptools`を更新してみてください。
いままでのところpython-docx側でsetuptoolsに対する依存関係を明示していないので、手動で更新する必要があります。

[^python-docx-issue-594]: <https://github.com/python-openxml/python-docx/issues/594>

# テンプレート作成のヒント集 {#sec:develop-template}

実はこの話題は別の方が研究中です。[参考書籍](#references)に列挙しておきます[^refer-doujinshi]。
内容を見てみると自分とほとんど同じことしてますね。この本の存在意義が薄れちゃいますね。

[^refer-doujinshi]: 参考書籍類は大半が同人誌です。狭い世界ですね。

## 下準備：PandocのDocx対応状況を確認しよう

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

で出力した`template.docx`を参照します。このファイルを叩き台にして独自テンプレートにするのが
一般的な使われ方だと思います([@sec:develop-template])^[ここまでテンプレ]。

## デフォルトテンプレートに採用されているスタイル {#sec:default-styles}

先のコマンドで出力したデフォルトテンプレートファイルに採用されているスタイルをPythonで抽出してみました。
以下のようなPythonコードを使っています。動作には`python-docx`パッケージを必要とします。
このスクリプトは**`template.docx`ファイルをWordで開く前に**実行してください。

\\newpage

```python
import docx

doc = docx.Document("template.docx") # default template
styles = [s.name for s in doc.styles]
styles.sort() # sort by alphabetic order
print(styles)
```

実行結果を示します。日本語名と種類を併記します。
"脚注参照"と"脚注文字列"に対応する英語スタイル名はなぜか*先頭が小文字にすり替わります*。

Table: List of Styles

| スタイル名                | 日本語名      | 種類 | 備考                                 |
|:-------------------------|:-------------|:----|:-------------------------------------|
| `Abstract`               |              | 段落 |                                      |
| `Author`                 |              | 段落 |                                      |
| `Bibliography`           | 文献目録      | 段落 |                                      |
| `Block Text`             | ブロック      | 段落 |                                      |
| `Body Text`              | 本文         | 段落 |                                      |
| `Body Text Char`         |              | 文字 |                                      |
| `Caption`                | 図表番号      | 段落 |                                      |
| `Captioned Figure`       |              | 段落 |                                      |
| `Compact`                |              | 段落 | 番号なしリストに適用されるっぽい         |
| `Date`                   | 日付         | 段落 |                                      |
| `Default Paragraph Font` |              | 文字 |                                      |
| `Definition`             |              | 段落 |                                      |
| `Definition Term`        |              | 段落 |                                      |
| `Figure`                 |              | 段落 |                                      |
| `First Paragraph`        |              | 段落 | Pandoc独自スタイル。"標準"スタイルを継承 |
| `Footnote Reference`     | 脚注参照      | 段落 | *`footnote`*にすり替わる　            |
| `Footnote Text`          | 脚注文字列    | 段落 | `footnote`にすり替わる                |
| `Heading 1`              | 見出し 1      | 段落 |                                      |
| `Heading 2`              | 見出し 2      | 段落 |                                      |
| `Heading 3`              | 見出し 3      | 段落 |                                      |
| `Heading 4`              | 見出し 4      | 段落 |                                      |
| `Heading 5`              | 見出し 5      | 段落 |                                      |
| `Heading 6`              | 見出し 6      | 段落 |                                      |
| `Heading 7`              | 見出し 7      | 段落 |                                      |
| `Heading 8`              | 見出し 8      | 段落 |                                      |
| `Heading 9`              | 見出し 9      | 段落 |                                      |
| `Hyperlink`              | ハイパーリンク | 段落 |                                      |
| `Image Caption`          |              | 段落 | 画像のタイトルに適用される              |
| `Normal`                 | 標準         | 段落 |                                      |
| `Subtitle`               | 副題         | 段落 |                                      |
| `TOC Heading`            | 目次の見出し  | 段落 | スペース大事                          |
| `Table`                  |              | 表  |                                      |
| `Table Caption`          |              | 段落 | 表のタイトルに適用される                |
| `Title`                  | 表題         | 段落 |                                      |
| `Verbatim Char`          |              | 文字 |                                      |

## 熟成プラン１：Pandocデフォルトテンプレートを編集する

テンプレートファイルの変更は無制限に行うことができますが、それらの変更の継承具合（全て正しく
適用されて出力されるか）はわかりません。一方でデフォルトファイルのスタイルや情報は基本的に
継承されるということです。したがってデフォルト設定を大きく逸脱させないテンプレートにします。

## 熟成プラン２：Microsoft謹製テンプレートを編集する

+:------------------------------------------------------------------------:+\
| **警告：これ正直ライセンス的に微妙です。頒布するものには使わないほうがいい、かも** |\
+--------------------------------------------------------------------------+\

マイクロソフトさんはつよいので、Word/Excel/PowerPoint用のテンプレート例を公開しています[^templates-for-word]。
このテンプレをダウンロードして流用してしまえというのがプランBです。

[^templates-for-word]: <https://templates.office.com/en-US/templates-for-Word>

\\newpage

### 英語のスタイル名を用意する

内部ではWordによる**やんごとなきスタイルID変更**が行われてしまっています。
文字コード周辺の問題で、UTF8なスタイル名を見つけるとスタイルIDが適当なランダムっぽい値に
変更されちゃうようです^[<https://github.com/jgm/pandoc/issues/5074#issuecomment-440938368>]。
こういうとこやぞWord...

### スタイルIDとスタイル名が一致するとは限らない

ちょっと用語を解説します。さきほどからスタイル名とかスタイルIDとか述べていますが、
簡単に言うと、`スタイルID`がWord内部での参照IDで、`スタイル名`はユーザが目にするスタイルの名前です。
これはユーザがスタイルを追加するときに名付ける名前も含みます。これらの文字列はたいてい等しいのですが、
スタイル名に非英語圏の文字が使われている場合や半角スペースが含まれていると一致しなくなります。
`Heading 1`スタイルのIDが`Heading1`だったりします。

ややこしいことに、一部組み込みスタイル名は
各言語に翻訳されてUIに表示されます[^does-anyone-know-how-to-stop-this]。
例えば日本語版でdocxファイルを新規作成して、適当な日本語文字列にデフォルトの`表題`スタイルを適用し、
保存したものを英語版で開くと`Title`と表示されます。

[^does-anyone-know-how-to-stop-this]: どなたかこれをやめさせる方法知りませんかね

先述の通り、やんごとない状況下[^specific-situation]ではスタイル名が英語ではなくなる可能性があることから、
Wordは一律に非組込みスタイルに（擬似ランダムな）英数文字列のスタイルIDを与えます。これによってUIでは
`TOC Heading`であるスタイルのIDが`af2`だったりする*重大事故*が起きます。

[^specific-situation]: 非英語圏版またはOS

手持ちのファイルがどんな目にあっているのかを参照するため以下のようなコードで確認してみました。
段落スタイルのうちスタイルIDと"スタイル名から半角スペースを取り除いたもの"が一致しないものを表示します。

Listing: スタイルID抽出 {#lst:extract-style-id}

```python
import docx
from docx.enum.style import WD_STYLE_TYPE

doc = docx.Document("ref.docx")
st = [s for s in doc.styles if s.type==WD_STYLE_TYPE.PARAGRAPH]  # pick up paragraph styles
for s in st:
    name= s.name
    short = name.replace(" ", "")
    if s.style_id != short:
        print(name, s.style_id, short)
```

結果は次ページの通り、一見では命名法則があるのかどうかもわかりません。

\\newpage

Table: スタイル名/短縮スタイル名/スタイルID {#tbl:style-name-vs-id-looks-unrelated}

| Style Name     | Style Name (Shorten) | Style ID |
|:---------------|:---------------------|:---------|
| Normal         | Normal               | a0       |
| Heading 1      | Heading1             | 1        |
| Heading 2      | Heading2             | 20       |
| Heading 3      | Heading3             | 30       |
| Heading 4      | Heading4             | 4        |
| Heading 5      | Heading5             | 5        |
| Body Text      | BodyText             | a4       |
| Title          | Title                | a6       |
| Subtitle       | Subtitle             | a8       |
| Date           | Date                 | aa       |
| Bibliography   | Bibliography         | ab       |
| Block Text     | BlockText            | ac       |
| footnote text  | footnotetext         | ad       |
| Caption        | Caption              | ae       |
| TOC Heading    | TOCHeading           | af2      |
| toc 1          | toc1                 | 11       |
| toc 2          | toc2                 | 26       |
| toc 3          | toc3                 | 32       |
| Balloon Text   | BalloonText          | afc      |
| Quote          | Quote                | aff0     |
| Intense Quote  | IntenseQuote         | 22       |
| List Bullet    | ListBullet           | a        |
| List Bullet 2  | ListBullet2          | 2        |
| List Bullet 3  | ListBullet3          | 3        |
| endnote text   | endnotetext          | aff7     |

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

# 更新履歴 {-}

## Revision5.0（技術書典６） {-}

- その後も仕事PCはKSﾍﾟﾙｽｷｰに振り回されているけどプロキシ設定でhttp遮断問題は回避できるようになったので当面は大丈夫そう
- 本業でいしころころころしてて書く時間がないんだょ
- Win7の環境下でsvgbobから生成したPNGへのリンクが壊れるわけわからんバグに遭遇した
けどそのうちOS入れ替わるしほっといてもいいよね？？
- ｱｲｴｪｪ!右端!右端ﾅﾝﾃﾞ（ﾐｷﾚﾘｱﾘﾃｨｼｮｯｸ（表の幅がページ幅を超えてもセル内で折り返してくれない）を受けている）
- Pandocの更新頻度ェ...

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}

+------+\
| hoge |\
+------+\
