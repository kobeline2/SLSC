# AGENTS.md — Project Context for Codex

## 研究概要

日本の水文頻度解析で使われている **SLSC（Standard Least-Squares Criterion）** の問題点を統計的に整理し，尤度・情報量基準への移行を提案する研究．

**核心の手続き**：ある確率分布（sampler）からサンプルを生成 → 別の分布（model）を当てはめ → SLSC / AIC / Cross-entropy で評価するシミュレーション研究．

## 論文の方向性

スライド「SLSCの整理」（65ページ）に基づき，1〜2本の論文にまとめる予定：

- **プランA論文**：SLSC の有意水準ベース棄却限界の提案（分布別・n別の棄却閾値表）
- **プランB論文**：SLSC → MLE + AIC への移行の正当化（国際整合・理論的一貫性）

**問題意識**：
- 現行の SLSC < 0.04 という閾値は恣意的（サンプルサイズ・分布に依存）
- 非線形標準化（3P対数正規のlog変換）により，3PLNが構造的に有利になるバイアスがある
- 気候変動に伴う非定常解析への移行障壁になっている

## ディレクトリ構成

```
SLSC/
├── AGENTS.md              ← このファイル
├── main.m                 ← エントリーポイント（デモ・実行例）
├── +simstudy/             ← コアパッケージ
│   ├── +config/           ← シミュレーション設定（true params, theta0）
│   ├── +distributions/    ← 分布の実装（rnd, pdf, loglike, icdf, cdf）
│   ├── +estimators/       ← パラメータ推定（MLE.m）
│   ├── +metrics/          ← 評価指標（SLSC.m, AIC.m, Xentropy.m）
│   ├── +util/             ← ユーティリティ（変換・集計・プロット位置）
│   ├── +analysis/         ← 可視化・分析
│   └── +diagnostics/      ← 診断ツール
├── +experiments/          ← 実験ランナー（runBatch.m, run.m）
├── test/                  ← テストスクリプト
└── results/               ← シミュレーション出力（.mat ファイル）
```

## 対象分布

| 名前 | MATLAB識別子 | パラメータ |
|------|-------------|-----------|
| Gumbel | `gumbel` | alpha（位置），beta（スケール） |
| Generalized Extreme Value | `gev` | k（形状），sigma（スケール），mu（位置） |
| 3P Lognormal | `lnormal` | c（下限），mu（対数平均），sigma（対数標準偏差） |
| Log-Gamma (Pearson III) | `lgamma` | a（スケール），b（形状），c（位置） |
| sqrt-ET | `sqrtet` | a，b |
| Exponential (shifted) | `exponential` | c（下限），mu（スケール） |
| Normal | `normal` | mu，sigma |

真のパラメータは京都雨量データに基づく（`+simstudy/+config/base.m` 参照）．

## 重要な実装上の注意

### SLSC の定義
現在の `+simstudy/+metrics/SLSC.m` は**S空間（非線形標準化）**で計算している．
スライドの議論（p31–39）では，分布間の公平な比較には**X空間（線形標準化）**が望ましいと主張．
→ `SLSC_x`（X空間版）の実装追加が課題．

### 現在の SLSC.m の実装
- Plotting position: Cunnane式（alpha=0.4, beta=0.2）
- 正規化定数: q=0.99 の理論分位点差
- 分布ごとに異なる標準化関数 `sv(x)` を使用（非線形標準化）

### MLE の実装
- Gumbel: `evfit()` を流用（符号反転）
- GEV: `gevfit()` 使用
- 3P Lognormal: `fminunc` で最適化（非正則モデルに注意）
- Log-Gamma: `fmincon` で c < min(obs) を制約
- sqrt-ET: `fminunc` で最適化

### AIC の計算
`AIC = 2k - 2*logL`，k はパラメータ数（fieldnames で自動カウント）．

## コーディング規約

- MATLAB パッケージ構成（`+package/` ディレクトリ）
- パラメータは struct で管理（位置引数でなく名前付きフィールド）
- 分布関数はディスパッチャー経由で呼ぶ（`simstudy.distributions.rnd(model, N, theta)`）
- 再現性のために `RandStream('Threefry', 'Seed', seed)` を使用
- 結果は `results/<tag>/raw/rep****.mat` → `aggregate.mat` に集約

## 作業ログ（最終更新: 2026-04-03）

- プロジェクト構造の把握・AGENTS.md 作成
- 次のステップ：SLSC.m の統計的正確性の検証，X空間版SLSC の実装
