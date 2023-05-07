---
title: "R と Stata でマルチレベル分析"
emoji: "[:snowman:]"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [R, Stata, データ分析, マルチレベル]
published: false
---

# 記事について

この記事では R と Stata でマルチレベル分析を行う方法（の一部）を紹介します。

個人的な感覚としては、（大学や会社でライセンスをお持ちであれば）Stata の方がやや便利だなという印象があります。
R での実装方法も色々と調べてみましたが、Stata は R に比べて 1 つのコマンドでオプションを色々と設定できます。特に、マルチレベル分析では標準誤差や自由度の計算が問題になったりすると思いますが、この辺りも柔軟に設定可能でした。

なおここでは基本的な使い方の整理のみで、特殊なケースは扱っていません（今後別の記事として追加する可能性はあります）。また、数式等も記載しておりません。

# マルチレベル分析とは

学校や地域、職場などの階層構造を持つデータの分析方法の 1 つです。階層構造をもつデータでなぜマルチレベル分析が必要かについては様々な論文、教科書、記事などで紹介されています。ここでは大きく 2 つ取り上げます。

1.  サンプルの独立性の問題。よく使われる分析方法（回帰分析など）ではデータの独立性が仮定されているが、階層構造のあるデータはその仮定が成立しない。あるいはしにくい。
2.  集団レベルの影響と個人レベルの影響が区別できない。例えば、学習時間と学業成績の関係について、「学習時間の長い生徒は、短い生徒より学業成績が良い」のか、「学習時間が平均的に長い学校には、短い学校より成績の良い生徒が多い」のかの区別ができない。

こういった問題を解決し、分析結果からより実践的な解釈を行うためにマルチレベル分析を用います。ちなみにマルチレベル分析は混合効果モデルや階層線形モデル（線形モデルを扱う場合）などと呼ばれたりもします。

# 扱うデータ

こちら <http://www.mlminr.com/home> のサイトから、*Achieve* というデータセットを取得しました。列数が多いので、分析に必要な一部だけを取り出しています。列数の解釈は私の想像です。

-   `school`: 学校
-   `geread`: 読解力
-   `gevocab`: 語彙力
-   `senroll`: 入学年（違うかもしれません）

```
# A tibble: 6 × 5
     id school geread gevocab senroll
  <dbl>  <dbl>  <dbl>   <dbl>   <dbl>
1     1    767    3.5     3.1     463
2     2    767    1.2     2.8     463
3     3    767    2.1     1.7     463
4     4    767    1.6     2.1     463
5     5    767    3.7     2.4     463
6     6    767    2.4     2.4     463
```

# 分析 1： ランダム切片モデル

## R で実装

R で実装すると以下のようになります。R で実装するときは変数名を `datachieve` としています。パッケージには `{lmerTest}` を使っており、`(1|school)` と書くことで、切片にランダム効果を仮定できます。

`{lme4}` がマルチレベル分析を行う時の標準的なパッケージと思いますが、`{lmerTest}` で分析すると固定効果で P 値が計算されるようになります（`{lme4}` では計算されません） 。

```
model_achieve <- datachieve %>% 
  lmerTest::lmer(data = ., 
                 formula = geread ~ gevocab + senroll + (1|school))
```

結果はこちら。

Fixed effects をみると、語彙力の得点が高いほど読解力の得点が高いことがわかります。ですが、この時点では学校レベルと個人レベルの影響を区別することができません。

```
> summary(model_achieve)
Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
Formula: geread ~ gevocab + senroll + (1 | school)
   Data: .

REML criterion at convergence: 43152.1

Scaled residuals: 
    Min      1Q  Median      3Q     Max 
-3.0834 -0.5729 -0.2103  0.3212  4.4336 

Random effects:
 Groups   Name        Variance Std.Dev.
 school   (Intercept) 0.1003   0.3168  
 Residual             3.7665   1.9408  
Number of obs: 10320, groups:  school, 160

Fixed effects:
                Estimate   Std. Error           df t value Pr(>|t|)    
(Intercept)    2.0748819    0.1140074  237.2588776   18.20   <2e-16 ***
gevocab        0.5128708    0.0083734 9798.1335657   61.25   <2e-16 ***
senroll       -0.0001026    0.0002051  165.1744273   -0.50    0.618    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Correlation of Fixed Effects:
        (Intr) gevocb
gevocab -0.327       
senroll -0.901 -0.002
```
## Stata で実装

Stata では `mixed` コマンドでマルチレベル分析を実行できます（従属変数が連続値の場合）。
推定方法は制約付き最尤法（REML）とし、stddeviat で ランダム効果の推定値をデフォルトの分散から標準偏差に変更しています。
また、自由度の計算方法 dfmethod で変更しています。

```
mixed geread gevocab senroll || school:, reml stddeviat dfmethod(satterthwaite)
```

結果はこちら。概ね、R での分析結果と一致しています。

```
Mixed-effects REML regression                   Number of obs     =     10,320
Group variable: school                          Number of groups  =        160
                                                Obs per group:
                                                              min =         11
                                                              avg =       64.5
                                                              max =        162
DF method: Satterthwaite                        DF:           min =     164.74
                                                              avg =   3,399.41
                                                              max =   9,796.83
                                                F(2,   322.16)    =    1875.86
Log restricted-likelihood = -21576.049          Prob > F          =     0.0000

------------------------------------------------------------------------------
      geread | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     gevocab |   .5128708   .0083734    61.25   0.000     .4964572    .5292844
     senroll |  -.0001026   .0002051    -0.50   0.618    -.0005076    .0003024
       _cons |   2.074882   .1140075    18.20   0.000     1.850283    2.299481
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
school: Identity             |
                   sd(_cons) |   .3167648   .0290101      .2647171     .379046
-----------------------------+------------------------------------------------
                sd(Residual) |    1.94076   .0136119      1.914263    1.967623
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 116.48        Prob >= chibar2 = 0.0000
```
# 分析 2： 変数の中心化

## R で実装

マルチレベル分析のメリットに、「個人効果と集団効果の分離が可能」というものがあります。ここでは、その分析を試してみます。

`dataachieve2` として新たなデータセットを作成しています。

- `school`: 学校
- `gevocab_wsc`: 語彙力の得点から、各学校の平均点を引いたもの。つまり、各語彙力の得点から「学校の影響」を除外したもの（集団平均中心化）。
- `gevocab_gcm`: 語彙力に関する各学校の平均点から、全体の平均を引いたもの（全体平均中心化）。
- `senroll`: 入学年（違うかもしれません）
```
datachieve2 <- datachieve %>% 
  mutate(gevocab_sc = mean(gevocab), .by = school) %>% 
  mutate(gevocab_wsc = gevocab - gevocab_sc, .by = school) %>%
  mutate(gevocab_gcm = gevocab_sc - mean(gevocab))
```

分析モデルはこちら。なお今回は、切片だけでなく、学校レベルの影響を除いた個人レベルの得点（`gevocab_wsc`）にランダム効果を仮定しています。

```
odel_achieve2 <- datachieve2 %>% 
  lmerTest::lmer(data = ., 
                 formula = geread ~ gevocab_wsc + gevocab_gcm + senroll + (gevocab_wsc|school), 
                 control = lmerControl(optimizer = "optimx", optCtrl = list(method = "nlminb"))
                 )
```

結果はこちら。

Fixed effects の部分を確認すると、学校レベルの語彙力が読解力に及ぼす影響が大きいようです。

「学校レベル」の語彙力が高い場合、日常会話の中に多様かつ豊富な語彙が含まれることが想定されます。そうした会話に日常的に触れることが、結果的に生徒の読解力を高める可能性があります。個人レベル、集団レベルの影響を分離して分析することで、通常の回帰モデルでは難しい解釈に踏み込むことが可能になります。

```
Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
Formula: geread ~ gevocab_wsc + gevocab_gcm + senroll + (gevocab_wsc | school)
   Data: .
Control: lmerControl(optimizer = "optimx", optCtrl = list(method = "nlminb"))

REML criterion at convergence: 42945.4

Scaled residuals: 
    Min      1Q  Median      3Q     Max 
-3.7298 -0.5727 -0.2024  0.3065  4.8315 

Random effects:
 Groups   Name        Variance Std.Dev. Corr
 school   (Intercept) 0.07454  0.2730       
          gevocab_wsc 0.02059  0.1435   0.84
 Residual             3.66050  1.9132       
Number of obs: 10320, groups:  school, 160

Fixed effects:
                Estimate   Std. Error           df t value Pr(>|t|)    
(Intercept)   4.37309224   0.08762483 215.91295954  49.907   <2e-16 ***
gevocab_wsc   0.50815459   0.01476604 148.39123352  34.414   <2e-16 ***
gevocab_gcm   0.78721871   0.03166252 168.69352602  24.863   <2e-16 ***
senroll      -0.00006571   0.00016143 167.46570927  -0.407    0.685    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Correlation of Fixed Effects:
            (Intr) gvcb_w gvcb_g
gevocab_wsc  0.101              
gevocab_gcm  0.027  0.083       
senroll     -0.943  0.071 -0.021
```

## Stata で実装

Stata では以下のコマンドで実装できます。`school:` の後ろに `gevocab_wsc` を書くことで、個人レベルの語彙力にランダム効果を置いています。

```
mixed geread gevocab_wsc gevocab_gcm senroll || school: gevocab_wsc, reml stddeviat dfmethod(satterthwaite)
```

結果はこちら。R と微妙に異なっていますが、概ね同じ結果が得られています。

```
Mixed-effects REML regression                   Number of obs     =     10,320
Group variable: school                          Number of groups  =        160
                                                Obs per group:
                                                              min =         11
                                                              avg =       64.5
                                                              max =        162
DF method: Satterthwaite                        DF:           min =     147.54
                                                              avg =     164.55
                                                              max =     193.46
                                                F(3,   154.65)    =     543.60
Log restricted-likelihood = -21495.681          Prob > F          =     0.0000

------------------------------------------------------------------------------
      geread | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 gevocab_wsc |   .5106242   .0146601    34.83   0.000     .4816533     .539595
 gevocab_gcm |   .7361638   .0360317    20.43   0.000     .6649879    .8073398
     senroll |  -.0001229    .000184    -0.67   0.505    -.0004863    .0002405
       _cons |   4.397438   .0974275    45.14   0.000     4.205281    4.589594
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
school: Independent          |
             sd(gevocab_wsc) |     .14108   .0132633      .1173389    .1696246
                   sd(_cons) |   .2642735   .0276365      .2152975    .3243907
-----------------------------+------------------------------------------------
                sd(Residual) |     1.9143   .0135242      1.887975    1.940991
------------------------------------------------------------------------------
LR test vs. linear model: chi2(2) = 196.47                Prob > chi2 = 0.0000
```

# 分析 3： ポアソン回帰（ロバスト標準誤差）※ Stata のみ

最後に、マルチレベル分析でポアソン回帰を行う方法を紹介します。私が扱う分析では事象の発生率が低くないようなデータを扱うことがあります。その際、ロジスティック回帰分析でオッズ比を計算すると過剰推定になります。
この問題について、[Zou (2014)](https://academic.oup.com/aje/article/159/7/702/71883) がロバスト標準誤差を用いた修正ポアソン回帰分析を提案しています。

ここでは、その修正ポアソン回帰分析を Stata で実装します。

扱うデータは以下です。

- `gereadc`: 読解力の得点が平均以上 を $1$、平均未満を $0$ に置き換えたもの
- `gevocab_wsc`: 個人レベルの語彙力の得点から学校の影響を除外したもの
- `gevocab_gcm`: 学校レベルの語彙力の得点から全体平均を引いたもの
-  `senroll`: 入学年（違うかもしれません）

```
# A tibble: 6 × 6
     id school gereadc gevocab_wsc gevocab_gcm senroll
  <dbl> <fct>    <dbl>       <dbl>       <dbl>   <dbl>
1     1 767          0       -1.83       0.441     463
2     2 767          0       -2.13       0.441     463
3     3 767          0       -3.23       0.441     463
4     4 767          0       -2.83       0.441     463
5     5 767          0       -2.53       0.441     463
6     6 767          0       -2.53       0.441     463
```

コマンドはこちら。今回は切片にのみランダム効果を置いています。また、`vce(robust)` でロバスト標準誤差を、`irr` では回帰係数を指数変換しています。

```
mepoisson gereadc gevocab_wsc gevocab_gcm senroll || school:, vce(robust) irr
```

結果はこちら。

個人レベルの語彙力が $1$ 点上がれば読解力が平均以上になりやすい。また、学校レベルの読解力の平均が全体平均より高いほど、読解力が平均以上になりやすいことを示している。

```
Mixed-effects Poisson regression                Number of obs     =     10,320
Group variable: school                          Number of groups  =        160

                                                Obs per group:
                                                              min =         11
                                                              avg =       64.5
                                                              max =        162

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(3)      =    1219.20
Log pseudolikelihood = -7226.6938               Prob > chi2       =     0.0000
                               (Std. err. adjusted for 160 clusters in school)
------------------------------------------------------------------------------
             |               Robust
     gereadc |        IRR   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
 gevocab_wsc |   1.188471    .006252    32.82   0.000      1.17628    1.200788
 gevocab_gcm |   1.340731   .0316997    12.40   0.000     1.280018    1.404323
     senroll |   1.000057   .0001023     0.56   0.578     .9998564    1.000258
       _cons |   .3337302   .0184123   -19.89   0.000     .2995255     .371841
-------------+----------------------------------------------------------------
school       |
   var(_cons)|   3.39e-37   3.61e-37                      4.23e-38    2.72e-36
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to incidence-rate ratios.
Note: _cons estimates baseline incidence rate (conditional on zero random effects)
```

# 今後取り組みたいこと

今後は経時的に測定されたデータのモデリングや、より複雑なモデリングなども勉強してみたいです。また、マルチレベルによるポアソン回帰分析やロジスティック回帰分析など（一般化線形混合モデル）を R で実装する方法についても、もう少し色々と情報収集してみます。