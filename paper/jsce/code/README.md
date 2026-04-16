# SLSC+ジャックナイフ法 / AIC 比較コードの使い方メモ

このディレクトリには, 論文
`\subsection{SLSC+ジャックナイフ法および AIC との比較}`
で使う計算コードを置いています.

いまはスクリプトが増えてきているので, このメモでは

- どのファイルが中核で, どのファイルが入口なのか
- ふだんは何を編集すればよいのか
- どのスクリプトを使えば, どんな運用ができるのか

を, できるだけ順を追って説明します.

## 1. まず結論

ふだん使うのは, 基本的に次の 6 本だけです.

- `run_criterion_subset_all.m`
- `run_criterion_subset_base.m`
- `run_criterion_subset_jackknife.m`
- `run_criterion_subset_cases.m`
- `show_criterion_project_status.m`
- `rebuild_criterion_outputs.m`

逆に, 普段はあまり直接触らなくてよいのは次の 3 本です.

- `criterion_project.m`
  - 中核ロジックです. 通常は編集不要です.
- `run_criterion_compare.m`
  - 旧来の「全部を一気通貫で回す」版です.
  - いまの増分運用では, ふだんは使わなくて大丈夫です.
- `plot_criterion_compare.m`
  - 既存 summary から図だけを描き直す関数です.
  - 見た目をいじるときだけ触れば十分です.

つまり, 日常運用としては

1. 入口スクリプトを 1 本選ぶ
2. 上の `Edit here` ブロックだけ直す
3. MATLAB で実行する
4. 状況確認や図表更新は別スクリプトで行う

という使い方を想定しています.

## 2. まず理解しておくべき考え方

このコードは, `projectName` ごとに 1 つの「計算プロジェクト」を作って,
その中に `(gen, N)` ケースごとの結果を少しずつ保存していく方式です.

イメージとしては,

- プロジェクト全体
  - 対象分布の一覧
  - 対象標本数の一覧
  - 反復数 `rep`
  - seed
  - `Tref`
- ケース単位
  - `gen = gumbel, N = 50`
  - `gen = gev, N = 200`
  - `gen = lnormal, N = 950`
  - など

に分かれています.

この方式にした理由は,

- 「今日は 5 ケースだけ回したい」
- 「GEV の N=200 だけ, 後から jackknife を足したい」
- 「全部を一気に回すと数日かかるので, 日ごとに積み増したい」

という運用に対応するためです.

## 3. `projectName` とは何か

`projectName` は, その計算群の名前です.

例えば,

- `paper_main`
- `paper_short`
- `paper_test`
- `paper_jk_heavy`

のような名前を付けます.

同じ `projectName` を使う限り, そのプロジェクトでは

- `projectModels`
- `projectNlist`
- `rep`
- `seed`
- `Tref`
- `slscProfile`

が固定されます.

この値を途中で変えると, 既存ケースと整合しなくなるので,
コード側でエラーにして止めるようにしてあります.

したがって,

- 同じ条件の続き計算をしたいときは, 同じ `projectName`
- 条件を変えて別実験にしたいときは, 別の `projectName`

と考えてください.

## 4. 出力はどこに保存されるか

各プロジェクトの結果は,

`paper/jsce/out/criterion_projects/<projectName>/`

に保存されます.

その中には主に次ができます.

- `project.mat`
  - プロジェクト設定
- `cases/`
  - `(gen, N)` ごとの個別結果
- `criterion_summary.mat`
  - 集計済み summary
- `criterion_selection_rates.csv`
  - 真モデル選択率の CSV
- `criterion_pair_means.csv`
  - `(gen, fit, N)` ごとの平均値 CSV
- `criterion_selection_table.tex`
  - LaTeX 表
- `criterion_compare.pdf`
  - 比較図

個別ケースは

`cases/N{N}_{gen}.mat`

という名前で保存されます.

例えば,

- `N50_gumbel.mat`
- `N200_gev.mat`
- `N950_lnormal.mat`

のようになります.

## 5. 再現性について

このコードでは, 同じ `(gen, N, rep)` に対しては,
いつ回しても同じ観測標本 `obs` が使われるようにしています.

これは, 乱数の substream を

- プロジェクト全体の分布一覧
- プロジェクト全体の N 一覧
- `rep`

から一意に決めているためです.

そのため,

- 今日は 5 ケースだけ
- 明日は別の 6 ケース
- 来週, そのうち 2 ケースだけ jackknife

という回し方をしても, 同じケースでは同じ `obs` が使われます.

## 6. どのスクリプトをいつ使うか

### 6.1 `run_criterion_subset_all.m`

これは,

- 選んだ分布
- 選んだ `N`

の直積 `genList × Nlist` を,
`base + jackknife` までまとめて回すスクリプトです.

向いている場面:

- ケース数がまだ少ない
- とりあえず全部まとめて欲しい
- jackknife も含めて一気に回したい

編集する主な項目:

- `opts.projectName`
- `opts.projectModels`
- `opts.projectNlist`
- `opts.genList`
- `opts.Nlist`
- `opts.rep`
- `opts.Tref`
- `opts.useParallel`

### 6.2 `run_criterion_subset_base.m`

これは `base` 指標だけを回します.

ここでいう `base` は主に,

- SLSC
- AIC
- `P0`

などです.

jackknife は計算しません.

向いている場面:

- まず広く全体像を見たい
- jackknife が重いので後回しにしたい
- とりあえず base だけ積み増したい

### 6.3 `run_criterion_subset_jackknife.m`

これは, 既にあるケースに対して jackknife だけを追加するスクリプトです.

向いている場面:

- base は広く終わっている
- 重いケースだけ jackknife を追加したい
- 「GEV の N=200, 250 だけ jackknife を見たい」

このスクリプトを使うときは,
同じ `projectName` を使ってください.

### 6.4 `run_criterion_subset_cases.m`

これは, 直積ではなく,
任意の `(gen, N)` の組だけを明示指定して回すスクリプトです.

向いている場面:

- 「今日は 5 ケースだけ」
- 「Gumbel の 50, GEV の 200, LN3 の 950 だけ」
- 直積では無駄が多い

このスクリプトでは,

```matlab
opts.caseList = table( ...
    ["gumbel"; "gev"; "lnormal"], ...
    [50; 200; 950], ...
    'VariableNames', {'gen', 'N'});
```

のように, 行ごとにケースを指定します.

### 6.5 `show_criterion_project_status.m`

これは, どのケースがどこまで終わっているかを確認するスクリプトです.

表示される主な列:

- `gen`
- `N`
- `base_done`
- `jackknife_done`

よく使うタイミング:

- 今日どこまで回ったか確認したい
- 次にどのケースを追加で回すか決めたい
- 重複実行を避けたい

### 6.6 `rebuild_criterion_outputs.m`

これは, 既に保存されているケースから

- summary
- CSV
- TeX 表
- 図

を作り直すスクリプトです.

向いている場面:

- 何ケースか追加で計算したあと, 図表を更新したい
- 計算自体は済んでいて, 図だけ作り直したい
- 論文の表を最新化したい

## 7. まずはこの使い方がおすすめ

迷ったら, 次の 3 段運用がいちばん扱いやすいです.

### 段階 1. base を広く回す

`run_criterion_subset_base.m` を使って,
分布と `N` をやや広めに設定して base だけ計算します.

### 段階 2. 重いケースにだけ jackknife を足す

`show_criterion_project_status.m` で状況を見ながら,
`run_criterion_subset_jackknife.m` で必要なケースにだけ jackknife を追加します.

### 段階 3. 図表を更新する

`rebuild_criterion_outputs.m` を実行して,
CSV, TeX 表, PDF 図を更新します.

## 8. 典型例

### 例 1. A, B, C の分布を N=50,100,150 で一気に回す

使うスクリプト:

- `run_criterion_subset_all.m`

編集例:

```matlab
opts.projectName = "paper_main";
opts.projectModels = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
opts.projectNlist = [50, 100, 150, 200, 250];

opts.genList = ["gumbel", "gev", "lgamma"];
opts.Nlist = [50, 100, 150];

opts.rep = 100;
opts.stage = "all";
```

これで,

- `gumbel × 50,100,150`
- `gev × 50,100,150`
- `lgamma × 50,100,150`

を全部回します.

### 例 2. まず base だけ広く回し, あとで一部に jackknife

最初に使うスクリプト:

- `run_criterion_subset_base.m`

編集例:

```matlab
opts.projectName = "paper_main";
opts.genList = ["gumbel", "gev", "lnormal"];
opts.Nlist = [100, 150, 200, 250];
opts.stage = "base";
```

あとで使うスクリプト:

- `run_criterion_subset_jackknife.m`

編集例:

```matlab
opts.projectName = "paper_main";
opts.genList = ["gev"];
opts.Nlist = [150, 200];
opts.stage = "jackknife";
```

これで, 同じ `paper_main` プロジェクトのうち,
`gev` の `N=150,200` にだけ jackknife が追加されます.

### 例 3. 今日は 5 ケースだけ回したい

使うスクリプト:

- `run_criterion_subset_cases.m`

編集例:

```matlab
opts.projectName = "paper_main";
opts.caseList = table( ...
    ["gumbel"; "gev"; "sqrtet"; "exponential"; "lnormal"], ...
    [50; 200; 250; 300; 950], ...
    'VariableNames', {'gen', 'N'});
opts.stage = "all";
```

これは直積ではなく,
その 5 ケースだけを回します.

## 9. 実際の実行方法

MATLAB で, まず一度だけ

```matlab
addpath('/Users/takahiro/Documents/git/SLSC/paper/jsce/code')
```

を実行します.

そのあと, 例えば

```matlab
out = run_criterion_subset_base();
```

や

```matlab
tbl = show_criterion_project_status();
```

を実行します.

図表だけ更新したいときは

```matlab
out = rebuild_criterion_outputs();
```

です.

## 10. よく編集する項目の意味

### `projectModels`

そのプロジェクト全体で扱う候補分布の一覧です.

通常は

```matlab
["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"]
```

を使います.

### `projectNlist`

そのプロジェクト全体で扱う `N` の一覧です.

例えば

```matlab
[50, 100, 150, 200, 250, 300, 400, 500, 700, 950]
```

です.

この一覧にない `N` は, そのプロジェクトでは使えません.

### `genList`

今日回したい `gen` の一覧です.
`Nlist` と直積で使われます.

### `Nlist`

今日回したい `N` の一覧です.
`genList` と直積で使われます.

### `caseList`

直積ではなく, 任意の `(gen, N)` 組を直接指定したいときに使います.

### `rep`

各ケースの反復数です.

### `Tref`

jackknife 幅を計算する再現期間です.

### `useParallel`

`true` ならケース単位で並列化します.
重い計算では基本的に `true` でよいです.

### `publishToPaper`

`true` にすると, 再生成した表や図を論文本体の既定位置にもコピーします.
普段は `false` でよく, 論文反映の直前だけ `true` にする運用でもよいです.

### `force`

既に終わっているケースでも, もう一度上書き実行したいときに使います.

## 11. 何を変えてはいけないか

同じ `projectName` のまま, 次を途中で変えないでください.

- `projectModels`
- `projectNlist`
- `rep`
- `seed`
- `Tref`
- `slscProfile`

これらを変えたいなら, 新しい `projectName` を作ってください.

## 12. どのファイルを無視してよいか

この比較計算に関しては,
まず `paper/jsce/code/` だけ見れば十分です.

以前の図作成用にある

- `paper/jsce/scripts/`

のスクリプトは, この `SLSC+ジャックナイフ法 / AIC` の増分運用とは別物と考えて大丈夫です.

また,

- `run_criterion_compare.m`

は旧来の一気通貫版なので,
いまの「少しずつ積み増す」運用では, 基本的に使わなくて構いません.

## 13. 最小限のおすすめ運用

迷ったら, まずは次だけ覚えておけば十分です.

1. `run_criterion_subset_base.m` で広く回す
2. `show_criterion_project_status.m` で進捗を見る
3. `run_criterion_subset_jackknife.m` で必要なところだけ jackknife を足す
4. `rebuild_criterion_outputs.m` で図表を更新する

任意の少数ケースだけ欲しいときだけ,
`run_criterion_subset_cases.m` を使う, という考え方です.

## 14. 補足

必要なら次の段階で,

- 入口スクリプトの数をさらに減らす
- `paper_main_base.m`, `paper_main_jk.m` のように, もっと名前を具体化する
- `projectName` ごとに専用スクリプトを作る

こともできます.

もし現時点でもまだ分かりづらければ,
次は「あなたの普段の運用に合わせた 2 本か 3 本だけを残す」方向に整理できます.
