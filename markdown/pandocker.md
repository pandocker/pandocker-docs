# *Pandocker*（本題）

*Pandocker*のしくみ・内部構造について解説します。

## Logic

*Pandocker*はGNU Make、TeXLive、Pandoc、フィルタ類、テンプレート類を一つのDockerイメージ上にパッケージしたものです。

Makeの仕組みによってPandocのオプションやフィルタの適用順を覚えておく必要がなくなります。TeXLiveが予めインストール済みの
イメージなのでLaTeX周りの悩みがなくなります。HTML/DOCXテンプレートも用意されています。もちろんカスタムテンプレートを
適用することも、それらを常時使うようにイメージを拡張することもできます。

Pandoc・フィルタ・テンプレートがインストール済のDockerイメージなので同一入力・同一出力が担保されます。
これによってユーザは`docker run`が動作するかどうかだけを気にすればよくなります。

### Make

コンパイルの全体を管理するのはMakefile群です。変数定義`Makefile.in`・システム用`Makefile`・
ユーザ用`Makefile`の3種類に分けてあります。

ユーザMakefileはMakefile.inをインクルードし、必要なら自ファイル内で上書きし、最後にシステムMakefileをインクルードすることで
3ファイルを連結しながらプロジェクト固有の設定も反映させます。

[Makefile](data/makefiles.bob){.svgbob}

\newpage

### System config
##### Makefile.in

[system/Makefile.in](/usr/var/pandoc_misc/system/Makefile.in){.listingtable type=makefile}

\newpage

##### Makefile

[system/Makefile](/usr/var/pandoc_misc/system/Makefile){.listingtable type=makefile}

\newpage

##### config.yaml

[system/config.yaml](/usr/var/pandoc_misc/system/config.yaml){.listingtable type=yaml}

\newpage

### Project's config

##### Makefile

[user/Makefile](./Makefile){.listingtable type=makefile #lst:user-makefile}

##### config.yaml

[user/config.yaml](./markdown/config.yaml){.listingtable type=yaml #lst:user-config-yaml}

## Docker Images
### Alpine
##### 3.10
##### pandoc's official latex image
### Ubuntu
##### 16.04

- Base image
- Extending image

##### 18.04

- Base image
- Extending image

## Installation
### Mac
### Linux
### Windows
## Document
