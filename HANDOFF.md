# HANDOFF

このリポジトリを別の PC / 別の Codex セッションで再開するためのメモです。

## Current Branch

- 推奨作業ブランチ: `codex/slsc-next`
- このブランチは現時点で `main` と同じ先頭です
- `paper/` 以下の TeX 原稿もこのブランチに入っています

## Recent Context

直前までに main に入っている作業:

- distributions API を統一
  - `rnd(model, N, theta)`
  - `pdf(model, x, theta)`
  - `cdf(model, x, theta)`
  - `icdf(model, u, theta)`
  - `loglike(model, data, theta)`
- `cdf_*` 実装を追加
- `MLE.m` と `paramMeta.m` の構造的不整合を修正
  - `normal/norm` の揺れを吸収
  - `gumbel`, `lgamma` の制約を修正
- `experiments/run.m` を現行 cfg 形式に合わせて整理
- `lgamma` を shifted gamma / Pearson III として説明・実装を整合
- `lnormal` の説明を整合し、`SLSC` 内の lognormal 変換を修正
- `SLSC` を整理
  - `+simstudy/+metrics/SLSC.m` は S-space 版
  - `+simstudy/+metrics/SLSC_x.m` を追加
  - `+simstudy/+metrics/slscCore.m`
  - `+simstudy/+metrics/slscTransform.m`
- validation 導線を追加
  - `+simstudy/+validation/runDistributionCheck.m`
  - `+simstudy/+validation/runSuite.m`
- scripts を追加
  - `init.m`
  - `scripts/checkMetricSingle.m`
  - `scripts/checkSlscTransform.m`
  - `scripts/runValidationModel.m`
  - `scripts/runValidationSuite.m`

## Confirmed So Far

- 6分布で `runDistributionCheck` は全項目 OK
- `lgamma` 再確認も通過
- `scripts/checkMetricSingle.m` で自然な `SLSC` 値を確認済み

## Next Topic

次の論点:

- `gev`, `lgamma`, `sqrtet` の S空間変換が文献上の定義と一致しているかをさらに詰める
- `scripts/checkSlscTransform.m` を使って確認する
- 必要なら `README.md` と `AGENTS.md` の分布説明も更新する

## How To Resume

Git:

```bash
git fetch origin
git switch codex/slsc-next
git pull --ff-only
```

MATLAB:

```matlab
cd /path/to/SLSC
init();
run("scripts/checkSlscTransform.m")
```

## Notes

- `local/` は Git 管理外
- scratch 出力は `local/scratch/` 配下
- `scripts/` は対話的に試すための軽い入口
- `validation/` は確認用コードと保存物の整理用
