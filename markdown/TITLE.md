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

今更いうほどでもないですがこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。
原稿とテンプレートDocxファイルの編集、フィルタの動作確認はMacで行われました。
スクリーンショットを撮るのだけはWindowsマシンを使いました。

[^company-machine]: 筆者の会社支給のマシンは**いつの間にかKSﾍﾟﾙｽｷｰの設定が変更されて
HTTPが遮断されWSL上のaptが効かなくなってて本当にどうしようもなくなりました**。

WSLがちゃんと動かないWindows機をお使いの方は、*手元でのコンパイルを諦めて*
外部CIサービスを利用してください。KSﾍﾟﾙｽｷｰは即時削除してください。

この本は、

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
一般的な使われ方だと思います([@sec:develop-template])。

## デフォルトテンプレートに採用されているスタイル {#sec:default-styles}

先のコマンドで出力したデフォルトテンプレートファイルに採用されているスタイルをPythonで抽出してみました。
以下のようなPythonコードを使っています。動作には`python-docx`パッケージを必要とします。
このスクリプトは**`template.docx`ファイルをWordで開く前に**実行してください。

```python
import docx

doc = docx.Document("template.docx") # default template
styles = [s.name for s in doc.styles]
styles.sort() # sort by alphabetic order
print(styles)
```

実行結果を示します。日本語名と種類を併記します。

Table: List of Styles

| スタイル名                | 日本語名      | 種類 | 備考                                                     |
|:-------------------------|:-------------|:-----|:--------------------------------------------------------|
| `Abstract`               |              | 段落 |                                                         |
| `Author`                 |              | 段落 |                                                         |
| `Bibliography`           | 文献目録      | 段落 |                                                         |
| `Block Text`             | ブロック      | 段落 |                                                         |
| `Body Text`              | 本文          | 段落 |                                                         |
| `Body Text Char`         |              | 文字 |                                                         |
| `Caption`                | 図表番号      | 段落 |                                                         |
| `Captioned Figure`       |              | 段落 |                                                         |
| `Compact`                |              | 段落 | 番号なしリストに適用されるっぽい                            |
| `Date`                   | 日付          | 段落 |                                                         |
| `Default Paragraph Font` |              | 文字 |                                                         |
| `Definition`             |              | 段落 |                                                         |
| `Definition Term`        |              | 段落 |                                                         |
| `Figure`                 |              | 段落 |                                                         |
| `First Paragraph`        |              | 段落 | Pandoc独自スタイル。"標準"スタイルを継承                    |
| `Footnote Reference`     | 脚注参照      | 段落 | Wordで開いて保存して再度実行すると`footnote reference`になる |
| `Footnote Text`          | 脚注文字列    | 段落 | Wordで開いて保存して再度実行すると`footnote text`になる      |
| `Heading 1`              | 見出し 1      | 段落 |                                                         |
| `Heading 2`              | 見出し 2      | 段落 |                                                         |
| `Heading 3`              | 見出し 3      | 段落 |                                                         |
| `Heading 4`              | 見出し 4      | 段落 |                                                         |
| `Heading 5`              | 見出し 5      | 段落 |                                                         |
| `Heading 6`              | 見出し 6      | 段落 |                                                         |
| `Heading 7`              | 見出し 7      | 段落 |                                                         |
| `Heading 8`              | 見出し 8      | 段落 |                                                         |
| `Heading 9`              | 見出し 9      | 段落 |                                                         |
| `Hyperlink`              | ハイパーリンク | 段落 |                                                         |
| `Image Caption`          |              | 段落 | 画像のタイトルに適用される                                  |
| `Normal`                 | 標準          | 段落 |                                                         |
| `Subtitle`               | 副題          | 段落 |                                                         |
| `TOC Heading`            | 目次の見出し   | 段落 | スペース大事                                              |
| `Table`                  |              | 表   |                                                         |
| `Table Caption`          |              | 段落 | 表のタイトルに適用される                                   |
| `Title`                  | 表題          | 段落 |                                                         |
| `Verbatim Char`          |              | 文字 |                                                         |

## 熟成プラン１：Pandocデフォルトテンプレートを編集する

テンプレートファイルの変更は無制限に行うことができますが、それらの変更の継承具合（全て正しく
適用されて出力されるか）はわかりません。一方でデフォルトファイルのスタイルや情報は基本的に
継承されるということです。したがってデフォルト設定を大きく逸脱させないテンプレートにします。

## 熟成プラン２：Microsoft謹製テンプレートを編集する

+:------------------------------------------------------------------------:+
| **警告：これ正直ライセンス的に微妙です。頒布するものには使わないほうがいい、かも** |
+--------------------------------------------------------------------------+

マイクロソフトさんはつよいので、Word/Excel/PowerPoint用のテンプレート例を公開しています[^templates-for-word]。
このテンプレをダウンロードして流用してしまえというのがプランBです。

[^templates-for-word]: <https://templates.office.com/en-US/templates-for-Word>

### 英語のスタイル名を用意する

内部ではWordによる**やんごとなきスタイルID変更**が行われてしまっています。
文字コード周辺の問題で、UTF8なスタイル名を見つけるとスタイルIDが適当なランダムっぽい値に
変更されちゃうようです^[<https://github.com/jgm/pandoc/issues/5074#issuecomment-440938368>]。
こういうとこやぞWord...

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

- その後KSﾍﾟﾙｽｷｰの設定は是正され無事人権が回復しました。助かったｗ
- 特定の条件下でsvgbobから生成したPNGへのリンクが壊れるわけわからんバグに遭遇した

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}
