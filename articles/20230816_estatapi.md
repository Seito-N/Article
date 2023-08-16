---
title: "R で e-Stat のデータを取得する方法"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [公的統計, R]
published: false
---
# 記事の内容

R の `{estatapi}` パッケージを利用して [e-Stat](https://www.e-stat.go.jp/) から公的統計を取得する方法をまとめています。e-Stat とは、日本の統計を閲覧するためのポータルサイトです。

# estatapi とは

このパッケージを利用すると、R から e-Stat の API にアクセスすることができます。`{estatapi}` に関する文書は[こちら](https://cran.r-project.org/web/packages/estatapi/readme/README.html)のサイトを、e-Stat の API については[こちら](https://www.e-stat.go.jp/api/)をご覧ください。


:::message
なお私は API を雰囲気でしか理解できておりません。
:::

# 扱う内容

上記リンクの公式文書では以下の 4 つが紹介されていますが、ここでは**どのデータを取得したいかは決まっており、メタ情報とデータの 2 つを取得したい**状況を想定します。以下のうち、2 と 3 についてまとめています。

1.  統計表情報取得
2.  メタ情報取得
3.  統計データ取得
4.  データカタログ情報取得

# 使い方

[労働力調査](https://www.stat.go.jp/data/roudou/index.html)という統計を取得して、性別ごとの正規雇用者、非正規雇用者の人数に関する時系列グラフを作成してみます。

## 事前準備

e-Stat の API を利用するにはユーザ登録やアプリケーション ID の取得が必要です。詳しくは[利用ガイド](https://www.e-stat.go.jp/api/api-info/api-guide)をご覧ください。登録作業自体は短い時間で簡単に済んだ記憶があります。

## メタ情報取得

パッケージの取得です。CRAN に登録されているので、`install.packages()` でインストールできます。

```{r}
pacman::p_load(tidyverse, estatapi, ggrepel)
```

アプリケーション ID はよく使うので `appId` としておきます。

```
appId <- "ここに取得したアプリケーション ID を入力します。"
```

メタデータを取得する際に、`statsDataId` という引数を指定する必要があります。今回は[1-1-4 農林業・非農林業，雇用形態別雇用者数（2013年～）](https://www.e-stat.go.jp/stat-search/database?page=1&layout=datalist&toukei=00200531&tstat=000000110001&cycle=7&tclass1=000001040276&tclass2=000001040299&tclass3=000001040303&statdisp_id=0003078094&tclass4val=0) というデータを使用します。このリンク内にある**統計表表示 ID** が、上記の引数に与える数値になります。

```R: R
meta <- estat_getMetaInfo(appId = appId,
                          statsDataId = "0003078094")
```

メタ情報の内容を見てみます。

```{r}



windowsFonts(meiryo = "Meiryo UI")

```
dat <- estat_getStatsData(
  appId = appId,
  statsDataId = "0003078094",
  cdCat01 = "00", 
  cdCat02 = c("03", "10"), 
  cdCat03 = c("1", "2")
  ) %>% 
  select(!c(tab_code, cat01_code, cat02_code, cat03_code, 
            area_code, time_code))
```
