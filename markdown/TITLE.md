\newpage

\newpage

\toc

# まえがき {-}

このドキュメントは、コミケ９５にて発表した「私的Markdown-PDF変換環境を紹介する本４」の内容を
補完し、秘伝のWordドキュメントテンプレートを構築するガイド*にするつもりでしたが*、**闇があまりに深い**ので、
話題を「Luaフィルタいっぱいつくってみた」と「Alpineベース環境復活してみた」に絞ることにしました。
Wordの話はまた今度にします。

## 前提環境 {-}

この本では、Word2010以降が動作するWindows10機[^company-machine]、またはMacを
対象環境にします。Windows10のOSバージョンは1803以降を前提にします。前作の手順に従い
環境を構築してあるものとします。

[^company-machine]: 筆者の会社支給のマシンはついに第8世代Core-i7マシンにアップグレードされ、
多くの悩みが解消しました。長かった...

今更いうほどでもないですがこの本もDockerイメージとCIを使って原稿リポジトリからコンパイルされました。
原稿とテンプレートDocxファイルの編集、フィルタの動作確認はMacで行われました。
スクリーンショットを撮るのだけはWindowsマシンを使いました。[^pdf-print]

[^pdf-print]: 実用に堪えないので印刷はPDF出力を使用しました。

WSLがちゃんと動かないWindows機をお使いの方は、*手元でのコンパイルを諦めて*
外部CIサービスを利用してください。KSﾍﾟﾙｽｷｰは即時削除してください。

この本は、恒例のpandocker環境の更新情報と、テンプレートファイル作成のヒント集で
構成されています。

# 今回の更新情報は？！

## Pandocが~~2.6~~ ~~2.7~~ **2.7.3**に更新

まずは上流プログラムの更新情報です。Pandoc本家がバージョン2.6〜2.7.3を
リリースしました。[^pandoc-2.6][^pandoc-2.7][^pandoc-2.7.1][^pandoc-2.7.2][^pandoc-2.7.3]
更新内容はいろいろありますが、個人的に大事なのはPandoc式Markdown書式にタスクリストが
追加されたこと（\@2.6）です[^pandoc-issue-3051]。
多くの出力形式で対応していて、Docxでは箇条書きの黒丸の直後に四角か四角にチェック(X)が入った
文字が置かれます。PDF出力では黒丸の代わりに四角・チェック入り四角が使われます。

もうひとつはコミケ95直前に遭遇して困った末にレポートした、最高に意味わからんバグの修正です（\@2.6）。
どうやら上流ライブラリのバグだったようで、pandoc側では解析のためにスタックダンプまで
行われていました[^pandoc-issue-5177]。

[^pandoc-2.6]: <https://github.com/jgm/pandoc/releases/tag/2.6/>
[^pandoc-2.7]: <https://github.com/jgm/pandoc/releases/tag/2.7/>
[^pandoc-2.7.1]: <https://github.com/jgm/pandoc/releases/tag/2.7.1>
[^pandoc-2.7.2]: <https://github.com/jgm/pandoc/releases/tag/2.7.2>
[^pandoc-2.7.3]: <https://github.com/jgm/pandoc/releases/tag/2.7.3>
[^pandoc-issue-3051]: <https://github.com/jgm/pandoc/issues/3051>
[^pandoc-issue-5177]: <https://github.com/jgm/pandoc/issues/5177>

## python-docxが0.8.10に更新

*pandocker*内で後処理に使っているpython-docxのバージョンが上がったんですが、筆者を含む数名が
インストール不能状態になりました[^python-docx-issue-594]。結果的に*setuptools*のバージョンが古すぎたせいでした。
読者の中でpython-docxの更新に失敗したひとがいれば、まず`setuptools`を更新してみてください。
いままでのところpython-docx側でsetuptoolsに対する依存関係を明示していないので、手動で更新する必要があります。

[^python-docx-issue-594]: <https://github.com/python-openxml/python-docx/issues/594>

## WordドキュメントからMarkdownに逆変換するオプションを追加

よく考えたらいままでWordドキュメントから逆変換するための方策は用意して・されていませんでした。
そこでreverse-docxオプションを足してみることにしました。^[オプションとか言ってますが
実際はMakefileのターゲットです。]実際のPandocコマンドオプションは以下のようになっています：

```makefile
PANREVERSEDOCX = -f docx-styles+header_attributes
PANREVERSEDOCX += -t markdown-simple_tables-multiline_tables+grid_tables+pipe_tables+header_attributes
PANREVERSEDOCX += --filter=pantable2csv
PANREVERSEDOCX += --extract-media=$(IMAGEDIR)
PANREVERSEDOCX += --wrap=preserve
PANREVERSEDOCX += --atx-headers

reverse-docx:
	$(PANDOC) $(PANREVERSEDOCX) $(TARGETDIR)/$(REVERSE_INPUT) -o $(MDDIR)/$(INPUT)
```

これに伴って`$(REVERSE_INPUT)`という変数を用意しました。変換元のWordファイル名を格納します。
デフォルトでは`reverse-input.docx`です。`Out/reverse-input.docx`から`markdown/TITLE.md`に変換します。
Wordドキュメント内の画像はPNGとして、`rIdxx.png`のような読みにくい名前で`images/media/`に保存されます。
出力ファイル内の画像リンクもここを参照します。Wordの機能で作った図形は正しく保存されない可能性が
高い^[Pandocの仕様です]ので注意が必要です。

## Ubuntu18.04系ブランチを追加 {#sec:ubuntu18-base-image}

従来の安定版Ubuntu16.04ベースのイメージに加えて、Luaフィルタの実験等のためにUbunutu18.04ベースの
環境を作り始めました[^base-image-branches]。

[^base-image-branches]: これに伴い、pandocker-baseイメージをUbuntu16系・18系に分けています。

従来の16系ベースイメージは`k4zuki/pandocker-base:latest`、
18系は`k4zuki/pandocker-base:18.04`を使用してください。

18系Pandockerは`docker pull k4zuki/pandocker:lua-filter`で入手できます。

## Pandoc公式サイトの実行バイナリはスタティックビルドだった

# Pandocker-Alpineの研究（？）を再開した話 {#sec:pandocker-alpine-restart}

以前行っていたAlpine LinuxベースのPandocker環境研究を再開しました。前回断念したときは
3.6をベースイメージにしていましたが、本家の更新が進んで現在は3.10系です。`docker pull k4zuki/pandocker-alpine`で
入手できます。

Pandocの実行ファイルは本家イメージをコピーしてくるようになっていて[^multi-stage-build]、
現在は`pandoc/latex:2.7.3`を使っています。その他にも、Rictyフォントを`Ubuntu:18.04`から
拾ってきています。

[^multi-stage-build]: DockerのMulti Stage Build 機能を使っています。

一つ問題があって、pandoc-crossrefフィルタのバージョンがやや古いもの(`0.3.0.0`)になっています。
pandoc-crossrefフィルタをソースからインストールするブランチを切ってみたのですが、pandoc-crossrefが
依存しているPandoc本体のビルドに2時間もかかってしまってやってられないですね。

# Luaフィルタでpanflute系フィルタを置き換えた話

従来のPythonライブラリ"panflute"を使用した各種フィルタを使った、特にWSLで使うときに
一部フィルタが**耐えられない遅さ**[^native-linux-reasonable-speed]
であったPandockerがLuaフィルタに移植したことで高速化されました。

[^native-linux-reasonable-speed]: WSLで遅いのはファイルシステムに*Write*アクセスしているからで、
ネイティブまたはVMのLinux上では実用的な速さです。たぶん。

## 移植元のPanflute系フィルタ

移植元のフィルタは複数のリポジトリに分散しています。PyPIには未登録なものがほとんどです。

- `pandocker-filters`
  - `pandocker-bitfield-inline`
  - `pandocker-listingtable-inline`
  - `pandocker-wavedrom-inline`
  - `pandocker-pantable-inline`
- `pandoc-docx-pagebreak-py`
  - `pandoc-docx-pagebreakpy`

## インストール

インストールはpipで行います：

```bash
$ pip install git+https://github.com/pandocker/pandocker-lua-filters.git
```

インストール先はPythonの設定によりますが、`/usr/local/share/lua/5.3/pandocker` または
`/usr/share/lua/5.3/pandocker`です。`/usr/local`か`/usr`かはPythonコンソールで

`````python
import site

print(site.getsitepackages()[0].split("/lib/")[0])
# site.getsitepackages() -> ['/usr/local/lib/python3.6/dist-packages','/usr/lib/...']
# site.getsitepackages()[0] -> '/usr/local/lib/python3.6/dist-packages'
# site.getsitepackages()[0].split("/lib/") -> ['/usr/local','python3.6/dist-packages']
# site.getsitepackages()[0].split("/lib/")[0] -> '/usr/local'
`````

などと入れてみると参考になります。手元で試したところ、Ubuntu系は`/usr/local`、Alpineは(APKで導入した場合)`/usr`を返しました。
Macはhomebrewで導入したので`/usr/local/Cellar/python/3.6.5/Frameworks/Python.framework/Versions/3.6`
などでした。

## 各フィルタの解説（呼び出し方とか使いどころとか）

このフィルタライブラリに含まれるフィルタはLaTeX出力専用・DOCX出力専用・汎用の3種に大別されます。また
大半は外部ライブラリを必要としませんが、一部既存のLua・Pythonライブラリを利用しているものもあります。

### `metadata-file.yaml`

このフィルタライブラリで共用されている、メタデータのデフォルト値を収めたファイルです。
このファイルはLuaファイルと同じディレクトリに置かれます。デフォルト値は原稿ファイル内で再定義することで上書きできます。

### `csv2table.lua`

CSVファイルへのリンクを表に変換します。`pandocker-pantable-inline`フィルタの置き換えです。
`pantable-inline`に比べて**WSL上での処理が有意に速くなります**。
部分切り出し・各列の幅・アライメント・ヘッダ列の有無の指定ができます。

アライメント未指定時はすべて`D`が指定されます。表の列数に比べて指定した列数が少ないときは`D`で補完します。

列幅指定の合計は1.0を超えてもエラーにはなりませんが、ページから表がはみ出す可能性があります。
列幅指定を省略した時は、Pandocがセルの内容に基づいていい感じにバランスを取ります。
表の列数に比べて指定した列数が少ないときは`0.0`で補完します。

- **`汎用`**
- 外部Luaライブラリ依存：
  - **`Penlight`**： `luarocks install penlight`
  - **`csv`**： `luarocks install csv`
- 外部Pythonライブラリ依存：**`なし`**
- オプション：
  - `subset_from=(y1,x1)`：部分切り出し始点(y1,x1)の指定。省略可能
  - `subset_to=(y2,x2)`：部分切り出し終点(y2,x2)の指定。省略可能
  - `alignment=DDD...`：列ごとのの幅寄せの指定。L(左寄せ) / C(中央寄せ) / R(右寄せ)またはD(デフォルト)。
省略可能（すべて`D`扱い）
  - `width=[0,...]`：列ごとの幅指定。ページ幅に対する相対値で指定する。省略可能(全て`0`扱い)
  - `header=true|false`：最初の行をヘッダとして扱うかどうかを指定する。省略可能(`true`)

#### 記法

リンクにtableクラスをつけます。個別の段落を見つけて処理する仕様なので、前後に空行を要します。

```markdown
<!--空行-->
[表のタイトル](path/to/file){.table subset_from=(y1,x1) subset_to=(y2,x2) alignment=DDDCC width=[0.2,0.2,0.2]}
<!--空行-->
```

### `listingtable.lua`

任意のテキストファイルへのリンクをコードブロックとして引用します。`pandocker-listingtable-inline`フィルタの移植版です。
部分切り出し・ファイルタイプ指定・行番号表示位置指定・表示開始行番号の指定ができます。

- **`汎用`**
- 外部ライブラリ依存：**`なし`**
- オプション：
  - `from=y1`： 部分切り出し開始行の指定。省略可能（`1`）
  - `startFrom=y3`： 表示開始行番号の指定。省略可能（`y3=y1`）
  - `to=y2`： 部分切り出し終了行の指定。省略可能（`-1`）
  - `type`： ファイルタイプの指定。省略可能（`plain`）
  - `numbers=left|right`： 行番号表示位置の指定。省略可能（`left`）

### `preprocess.lua`

原稿ファイルを連結します。GPPの置き換えです。文法が変わりますが**バックスラッシュを二重にする必要がなくなります**。
多重インクルードにも対応します。取り込まれたファイルは*Markdownファイルとして*Pandoc内部形式にマージされます。

- **`汎用`**
- 外部ライブラリ依存：**`なし`**
<!--- もしかしたら**`Penlight.List`**-->
- オプション：**`なし`**

#### 記法

ヘッダにC言語風のinclude節をつけるだけです。ヘッダの深さは制限しません。`#include`
と`"ファイル名.md"`の間には*必ず*スペースを入れる必要があります。

```markdown
# #include "連結したいファイル名.md"
```

### `removable-note.lua`

メタデータ`rmnote`をフラグとして、原稿内の`rmnote`クラスのDiv節をビルド時に削除します。
デフォルト値は**`false`**です。

- **`汎用`**
- 外部ライブラリ依存：**`なし`**
- オプション： なし

### `svgcomvert.lua`

SVG画像へのリンクを探し出してPNGまたはPDFに変換します。出力形式（`FORMAT`の値）で変換するかどうかを判断します。
画像の変換には`rsvg-convert`を使うので、予めインストールしパスを通しておく必要があります。
Linuxなら`librsvg-bin`などの名前でパッケージが用意されていると思います。

- **`汎用`**
- 外部ライブラリ依存：
  - **`rsvg-convert` / `librsvg`**： `apt install librsvg-bin`など

### `wavedrom.lua`

`pandocker-wabedrom-inline`と`pandocker-bitfield-inline`の置き換えです。
WavedromのPythonポーティング版"wavedrompy"に依存します。

- **`汎用`**
- 外部ライブラリ依存：
  - **`wavedrompy`**： `pip install wavedrom`

### `docx-pagebreak-toc.lua`

LaTeXコマンド`\newpage`と`\toc`をDOCX出力にも適用します。

- **`DOCX出力専用`**
- 外部ライブラリ依存：**`なし`**

### `docx-unnumberedheadings.lua`

- **`DOCX出力専用`**
- 外部ライブラリ依存：**`なし`**

### `tex-landscape.lua`

- **`LaTeX出力専用`**
- 外部ライブラリ依存：**`なし`**

### `tex-rowcolors-reset.lua`

- **`LaTeX出力専用`**
- 外部ライブラリ依存：**`なし`**

# #include "appendix.md" {.unnumbered parse=false}

# 更新履歴 {-}

## Revision5.0（C96） {-}

- その後も仕事PCはKSﾍﾟﾙｽｷｰに振り回されているけどプロキシ設定でhttp遮断問題は回避できるようになったので当面は大丈夫そう
- 本業でいしころころころしてて書く時間がないんだょ
- Win7の環境下でsvgbobから生成したPNGへのリンクが壊れるわけわからんバグに遭遇した
けどそのうちOS入れ替わるしほっといてもいいよね？？
- ｱｲｴｪｪ!右端!右端ﾅﾝﾃﾞ（ﾐｷﾚﾘｱﾘﾃｨｼｮｯｸ（pipe_tablesを使うとの幅がページ幅を超えてもセル内で折り返してくれない）を受けている）
- Pandocの更新頻度ェ...
- 7月18日の京アニ放火テロ事件で原稿が手につかない

![原稿PDFへのリンク](images/QRcode.png){#img:manuscript width=30%}
