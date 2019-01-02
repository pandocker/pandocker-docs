# このリポジトリは何
拙作のDockerイメージ*pandocker*の解説文書です。原稿はちょっと読みづらいのでHTMLまたはPDF出力されたものを参照ください。
最新の出力結果は[こちら](https://github.com/pandocker/pandocker-docs/releases/latest)にあります。
以前のバージョンは以下の通り：

## バージョン４：コミケ９５版

- Windows・DOCX特集編
- [ビルド`eaa7294`](https://github.com/pandocker/pandocker-docs/releases/tag/build-Dec-27-2018-eaa7294)

## バージョン３：技術書典４版

- 総集編
- [ビルド`7737f1a`](https://github.com/pandocker/pandocker-docs/releases/tag/build-7737f1a)

# pandocker-docs
Documents for _pandocker_ - Yet another ubuntu 16.04 based Docker image for pandoc

## For the first time to build your book
#### make repository and cd to it
```sh
mkdir /path/to/your/workspace
cd /path/to/your/workspace
```

#### git setup
```sh
git init
```

#### installation
```sh
docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make -f /var/pandoc_misc/Makefile init
> mkdir -p ./
> mkdir -p ./.circleci
> mkdir -p ./Out
> mkdir -p ./data
> mkdir -p ./markdown
> mkdir -p ./images
> cp -i /var/pandoc_misc/Makefile.txt ./Makefile
> cp -i /var/pandoc_misc/config.txt ./markdown/config.yaml
> cp -i /var/pandoc_misc/gitignore.txt ./.gitignore
> cp -i /var/pandoc_misc/circleci.yml ./.circleci/config.yml
> touch ./markdown/TITLE.md> mkdir -p ./

git add .
git commit -m"initial commit"
```

## Afterwards

- HTML output `docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make html`
- PDF output `docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make pdf`
- HTML and PDF output `docker run --rm -it -v $PWD:/workspace k4zuki/pandocker make html pdf`
