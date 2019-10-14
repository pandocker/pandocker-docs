# Pandocの「フィルタ」について {#sec:pandocs-filters }

Pandoc単体ではできないことでも、「フィルタ」を通すことで機能を拡張できます。

## おさらい：フィルタのしくみ
## Haskell made
## Lua made
### Speed
## Panflute/python made
## Extensions by filters
### Common behavior
#### Cross reference

- pandoc-crossref(<https://lierdakil.github.io/pandoc-crossref>)

[デフォルト値一覧](data/pandoc-crossref-defaults.yaml){.listingtable type=yaml}

#### CSV to table

- pandocker-lua-filters

#### Listing

- pandocker-lua-filters

#### Preprocess

- pandocker-lua-filters

#### Block comment

- pandocker-lua-filters

#### SVG to PNG/PDF at runtime

- pandocker-lua-filters

#### Table width

- pandocker-lua-filters

#### AAFigure

- pandocker-pandoc-filters

#### svgbob

- pandoc-svgbob-filter

#### blockdiag

- pandoc-blockdiag-filter

#### SVG to PNG/PDF

- pandocker-lua-filters

### HTML only behavior
### LaTeX only behavior
#### Landscape

- pandocker-lua-filters
```markdown
::: LANDSCAPE

:::
```

#### Table coloring

- pandocker-lua-filters

#### Pagebreak

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

### Word only behavior
#### Table of Contents

- pandocker-lua-filters
```markdown
<!--blank-->
\toc
<!--blank-->
```

#### Forced Page break

- pandocker-lua-filters
```markdown
<!--blank-->
\newpage
<!--blank-->
```

#### Unnumbered headings

- pandocker-lua-filters
```markdown
# Unnumbered Heading 1 {-}
## Unnumbered Heading 2 {-}
### Unnumbered Heading 3 {-}
#### Unnumbered Heading 4 {-}
```

#### Centering Image

- pandoc-docx-utils-py

### Post processing
#### docx-core-property-writer
