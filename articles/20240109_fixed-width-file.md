---
title: "R で大きな固定長ファイルをインポートする"
emoji: ""
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [R, Stata, 固定長ファイル]
published: false
---
# 記事の内容

この記事では、R を使って大きなサイズの固定長ファイルをインポートする方法を紹介します。

# 固定長ファイルとは

[IT 用語辞典](https://e-words.jp/w/%E5%9B%BA%E5%AE%9A%E9%95%B7.html)には以下のように記載されています。

> 固定長（fixed length）とは、データや要素、領域などの長さ（データ量）や個数があらかじめ決まっていて変化しないこと。対義語は「可変長」（variable length）。

例えばある固定長ファイルに `0001085` という値が保存されており、左から 4 番目までの `0001` は個人 ID を指し、5～7 番目の `085` は個人のスコアを指す、といったケースがあります。

固定長ファイルを分析用のデータフレームとしてインポートするためには、データのどの位置が何の変数を指しているかを明示する必要があります。ファイルのサイズが大きく変数も多い場合は大変手間がかかりますが、気合いで乗り越えるしかありません。

:::message
気合い以外の方法があれば教えてほしいです。
:::

# サンプルデータの確認

以下を実行し、サンプルデータを取得します。

```r
fwf_sample <- readr_example("fwf-sample.txt")
```

サンプルデータはこうなっています。

```r
> read_lines(fwf_sample)
[1] "John Smith          WA        418-Y11-4111" "Mary Hartford       CA        319-Z19-4341"
[3] "Evan Nolan          IL        219-532-c301"
```

# データをインポートする

`{readr}` パッケージの `read_fwf` を使います。様々なオプションがあるので、具体的な使い方は[こちら](https://readr.tidyverse.org/reference/read_fwf.html)をご確認いただければと思います。ここでは大きなファイルをインポートすることを想定したコードを残します。なお例として、`rest` 列の型を因子型に指定しています。

```r
read_fwf(file = fwf_sample, 
         col_positions = fwf_cols(name = c(1, 20), 
                                  rest = c(21, 29),
                                  ssn = c(30, 42)),
         col_types = cols(rest = col_factor())
         )
```

具体的には `file` で対象のファイルを、`col_positions` で列名と各変数の始点と終点を指定しています。結果は以下のようになります。

```r
# A tibble: 3 × 3
  name          rest  ssn         
  <chr>         <fct> <chr>       
1 John Smith    WA    418-Y11-4111
2 Mary Hartford CA    319-Z19-4341
3 Evan Nolan    IL    219-532-c301
```

# まとめ

大きな固定長ファイルのインポートを行うには、列名や変数の位置をミスのないように指定する必要があり、手間もかかります。Stata では `infix` コマンドで同様の操作が可能です。もしかしたらそちらについても書くかもしれません。