# Writer's Environment

この章では筆者の執筆環境[^war-crisis]を紹介していきます。

[^war-crisis]: こういうことを書くとだいたい宗教戦争になります。古くはVimとEmacs、最近はAtom（開発中止？したっぽい）とVSCodeなど。

## VS Code/Atom

筆者は以前Atom使いでした[^early-time]が、もう使ってません。起動が重すぎて耐えられなくなりました。

[^early-time]: このシリーズの初期の本はAtom上で書かれました。

VSCodeは使ったことがありません。

どちらもNodeJSベースですが、筆者がまさに苦手にしている言語[^war-crisis-2]なので、今後も当面は使わないと思います。

[^war-crisis-2]: 布教したくなる読者氏もいるかも知れませんが。**火種ですねぇ**。

## JetBrains IDE

筆者がAtom使いだった頃、会社ではPyCharm IDEが布教されました。本国でPythonを使った統合ライブラリの構築が進められ、その
実行・デバッグ環境として便利だったからです。その後会社と同じIDEのほうが利便性が高いのと、
十分高機能なMarkdownプラグインが見つかったことで、２年くらい使っています。最近はプラグインも一つ作りました。

ここから先の記述はすべてPyCharmの英語版を対象にします。そもそも日本語版があるのかはわかりませんが、適宜読み替えてください。

### プラグイン

Markdownの簡単なシンタックスハイライトとレンダリングの確認程度なら、ビルトインのMarkdownプラグインで十分です。
しかしながら、筆者にはこだわりがあるので、*Markdown Navigator*というプラグインの有料版を使っています。

>
> <https://plugins.jetbrains.com/plugin/7896-markdown-navigator>
>

### External Tools

External Toolsにコマンドと引数を登録すると、右クリックメニューから実行することができます。
たとえばコマンドに`docker`、引数に`run -it pandocker-alpine ...`などと入力しておくと、Pandockerを右クリックから呼び出せる、
という具合です。

### Live Templates

Live TemplateはVSCodeでいうところのスニペット機能です。

#### For Pandoc's markdown

#### For pandoc-crossref

#### For pandocker-lua-filters
