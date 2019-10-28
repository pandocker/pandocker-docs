# *Pandocker*（本題）

*Pandocker*のしくみ・内部構造について解説します。

## Logic

*Pandocker*はGNU Make、TeXLive、Pandoc、フィルタ類、テンプレート類を一つのDockerイメージ上にパッケージしたものです。

Makeの仕組みによってPandocのオプションやフィルタの適用順を考えずに済みます。TeXLiveが予めインストール済みの
イメージなのでLaTeX周りの悩みがなくなります。HTML/DOCXテンプレートも用意されています。もちろんカスタムテンプレートを
適用することも、それらを常時使うようにイメージを拡張することもできます。

Dockerイメージなので同一入力・同一出力が保証されます。
これによってユーザは`docker run`が動作するかどうかだけを気にすればよくなります。

### Make
コンパイルの全体を管理するのはMakefile群です。変数定義`Makefile.in`・システム用`Makefile`・
ユーザ用`Makefile`の3種類に分けてあります。

`Makefile.in`で定義された各変数、たとえばDOCXテンプレートのファイル名など、をユーザ用Makefileが上書きし
（なくてもいいんですよ！）、システム用Makefileがそれらを使ってコンパイルします。

[Makefile](data/makefiles.bob){.svgbob}

### System config
#### Makefile.in
#### Makefile
#### config.yaml
### Project's config
#### Makefile
#### config.yaml
## Docker Images
### Alpine
#### 3.10
#### pandoc's official latex image
### Ubuntu
#### 16.04

- Base image
- Extending image

#### 18.04

- Base image
- Extending image

## Installation
### Mac
### Linux
### Windows
## Document
