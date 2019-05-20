---
title: 私的Markdown-PDF変換環境を紹介するLT
author: "\_K4ZUKI\_"
# pandoc -t pptx -s  markdown/TITLE.md --slide-level=2 -o Out/pandoc-night.pptx
---

## 自己紹介

- [謎の半導体メーカーＤ社](https://dialog-semiconductor.com)
  - アプリケーションエンジニア
- Twitter: **\@\_K4ZUKI\_**
  - <https://twitter.com/_K4ZUKI_>
- GitHub: **k4zuki**
  - <https://github.com/k4zuki>

## TL; DR

- 同人誌原稿をMarkdownで
- Pandocのオプション多すぎ問題
- Makefileでオプションとフィルタを管理
- 叩き台としてのDockerイメージつくってみた
- HTML / Word / PDFに出力
- PyCharmで

## Pandocを見つけるまで（うろおぼえ）

- 「Ｄ社のBluetooth ICが入ったモジュール試してみた」的な本
- gitbookを使ってみたがPDF出力のレイアウトに不満
- *markdown pdf convert* で検索してPandocのサイトを発見

## Pandocのオプション多すぎて覚えられない

- PDF出力のためのコンバータ選択肢が複数存在 - 結局どれがいいのか
- Pandoc用・LaTeXディストリ用・フィルタ用のオプション多数

### なんとかして管理せな

- Makefileあたりが楽なのでは

## Makefile

- PDF出力・HTML出力のためのオプションリストを管理
  - <https://github.com/K4zuki/pandoc_misc>
- フィルタのリストを管理
- 固定値部分と変動部分を分割
- 前処理で原稿ファイルを連結
  - GPP <https://github.com/logological/gpp>
- OSを判定してスイッチする機構を入れていた\
= 煩雑

## 管理しきれないのでDockerイメージ作ろう

- Linux用・Mac用とか分けるの無理（同一性が保てない）
- NodeJS/Python/Haskell製のフィルタ
  - ユーザに3言語の環境の導入を強制することになる
  - 会社PCに入れるのも大変（Windowsだし
- バージョン組み合わせを管理するのも無理

### Dockerイメージしかなくね？

- DockerならWindowsでも動かせるしね

## 現環境(1)

- Ubuntu16.04ベース *k4zuki/pandocker* <https://cloud.docker.com/repository/docker/k4zuki/pandocker-base>
- レイヤを分割
  - LaTeX/Git/Makeとそれ以外
  - 派生イメージも比較的作りやすい
- Python系フィルタを多用して環境構築をシンプルに
  - *panflute*ライブラリを多用
  - 一部コンパイル済バイナリ^[pandoc-crossrefなど]も使用

## 現環境(2)

- リポジトリ初期化用pythonパッケージを用意
  - `pip3 install git+https://github.com/k4zuki/pandoc_misc.git`
  - `pandoc-misc-init`
- whalebrewパッケージも用意
  - <https://github.com/whalebrew/whalebrew>
  - ~Windowsは対象外~
- `whalebrew install whalebrew-pandocker`
- `pandocker init|initdir|clean|all|html|docx|\
reverse-docx|pdf`

## 現環境(3)

1. `pandoc-misc-init`
2. `pandocker <command>`

```bash
#!/usr/bin/env bash

docker run --rm -v /$PWD:/workdir k4zuki/pandocker $@
```

## まとめ

- Pandocの環境を組み上げてDocker化
- 派生イメージ歓迎
- 詳しいことはdocsで
  - <https://github.com/pandocker/pandocker-docs>
- 問題・質問はissueで <https://github.com/pandocker/pandocker/issues>
