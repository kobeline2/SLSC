# validation

分布実装の妥当性確認をまとめる置き場です。

## 目的

- `rnd`, `pdf`, `cdf`, `icdf`, `loglike`, `MLE` の自己整合性を確かめる
- 他の研究者に見せるための簡単な図と結果一覧を残す
- 分布ごとの不具合を早い段階で切り分ける

## コードの置き場

- 実行入口: `scripts/runValidationModel.m`
- 一括実行: `scripts/runValidationSuite.m`
- 実装本体: `+simstudy/+validation/`

## 出力先

ローカル保存先は `SLSC_LOCAL_ROOT` 配下の `validation/` です。

既定では次のようになります。

```text
<local-root>/
  validation/
    suite_YYYYmmdd_HHMMSS/
      index.csv
      gumbel/
        gumbel_diagnostic.png
        gumbel_report.mat
      gev/
      ...
```

## 最初にやる順番

1. `gumbel`
2. `normal`
3. `exponential`
4. `gev`
5. `sqrtet`
6. `lnormal`
7. `lgamma`

前半は既知分布なので、検証系自体の動作確認にも向いています。
