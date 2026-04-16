# SLSC project: 2本論文化の切り分けメモ

## 基本方針

現在のスライドと数値実験は情報量が多く, 1本に詰め込むと主張が拡散する.  
そのため, 論文は次の2本に切り分ける.

- 論文1: SLSCそのものの再検討
- 論文2: 3P LogNormal の非正則性と, 尤度/AIC への移行

両者の関係は次の通り.

- 論文1では, SLSC の構造的問題を理論とシミュレーションで明らかにする
- 論文2では, その問題の中でも特に深刻な 3P LogNormal と, 代替としての尤度/AIC を扱う

---

## 論文1の構想

### 仮タイトル案

- SLSC の再検討: 6分布シミュレーションと X空間 / S空間混同の理論的整理
- SLSC における標準化の役割の再検討と適合度評価への影響
- 水文頻度解析における SLSC の再評価: 6分布比較と非線形標準化の不合理

### 主眼

藤部型の数値実験を 6分布に拡張し, さらに SLSC における X空間 / S空間の混同が不合理であることを理論的に示す.

### 中心主張

1. SLSC はサンプルサイズ N に依存し, 固定閾値 0.04 による判定は一般には正当化できない.
2. SLSC が不変となるのは線形標準化のみであり, 非線形標準化を用いた SLSC は別指標である.
3. したがって, SLSC を用いるなら X空間で統一的に定義すべきであり, S空間での比較は分布間で公平ではない.

### 新規性

- 藤部論文の枠組みを 6分布に拡張
- X空間 / S空間の区別を明示
- 「SLSC が不変となるのは線形変換のみ」という命題を明示
- 非線形標準化は重み付きノルムを導入する, という整理

### 入れる内容

- 背景: SLSC の歴史的位置づけ
- 藤部論文の再確認
- 6分布 × 複数 fitting 分布によるモンテカルロ
- SLSC の N 依存性
- X空間 / S空間の定義
- 線形変換でのみ SLSC が不変であること
- 非線形標準化が 3PLN を過大評価しやすい数値結果
- 0.04 基準の「検定まがい」性

### 入れない方がよい内容

- 3P LogNormal の非正則性の完全証明
- AIC, 尤度, L-moments への大きな話
- 行政制度論
- 気候変動・非定常頻度解析への橋渡しの詳細

### 想定投稿先

- 土木学会論文集 B1
- 短めなら 7ページ程度に収める

### 章立て案

1. Introduction
2. Previous studies and problem setting
3. Definition of SLSC in X-space and S-space
4. Invariance under linear transformation and failure under nonlinear transformation
5. Monte Carlo experiments for six distributions
6. Discussion
7. Conclusion

---

## 論文2の構想

### 仮タイトル案

- 3P LogNormal の非正則性と水文頻度解析への含意
- 3P LogNormal の非正則性を踏まえた SLSC 実務の再検討
- 水文頻度解析における 3P LogNormal の問題点と尤度/AIC への移行

### 主眼

3P LogNormal は非正則モデルであり, その上 SLSC と非線形標準化の組み合わせにより実務上過大評価されやすい. この構造を明らかにし, 尤度/AIC への移行の必要性を論じる.

### 中心主張

1. 3P LogNormal は位置母数 c の境界で対数尤度が発散し, 通常の意味で正則な MLE 問題ではない.
2. にもかかわらず, SLSC の非線形標準化によって 3P LogNormal が選ばれやすい構造がある.
3. このため, 3P LogNormal を SLSC で採用する現在の実務は, 数百年確率雨量推定に系統的バイアスを入れうる.
4. 実務上は, 尤度 / AIC / L-moments 等に基づく枠組みに移行する方が合理的である.

### 新規性

- 3P LogNormal の非正則性を, 水文実務の文脈で正面から整理
- SLSC による 3P LogNormal 選好を理論とシミュレーションの両面から説明
- 実務移行シナリオを具体化

### 入れる内容

- 3P LogNormal の定義
- 非正則性の証明
- 既存の 3P LogNormal 利用実務の整理
- 3P LogNormal が SLSC で選ばれやすい数値実験
- 尤度 / AIC / L-moments の比較
- 実務への提言

### 章立て案

1. Introduction
2. Three-parameter LogNormal and its historical use
3. Non-regularity of the likelihood
4. Why SLSC tends to prefer 3P LogNormal
5. Comparison with likelihood-based criteria
6. Implications for hydrologic practice
7. Conclusion

---

## 両論文の切り分け原則

### 論文1の役割

- SLSC 全般の再評価
- 6分布を並べた一般論
- X空間 / S空間の整理
- 0.04 基準の危うさ

### 論文2の役割

- 3P LogNormal に焦点を絞る
- 非正則性というより深い問題
- 実務への直接的含意
- 尤度 / AIC への移行論

### 重複は最小限に

- 論文1で 3P LogNormal は「非線形標準化の代表例」として軽く触れる
- 非正則性の厳密な議論は論文2に回す
- 論文2では, 論文1の結果を必要最小限だけ再掲し, 3P LogNormal に集中する

---

## 現時点での判断

### 論文1で最も重要なこと

「藤部論文の6分布版」だけでは弱い.  
必ず
- X空間 / S空間の区別
- 線形変換でのみ不変
- 非線形標準化は別指標
を前面に出すこと.

### 論文2で最も重要なこと

3P LogNormal を感覚論で叩かず,
- 非正則性
- 推定法不明瞭性
- SLSC による過大評価
- 長期確率雨量への影響
を淡々と積み上げること.

---

## TODO

- [ ] 論文1の要旨案を作る
- [ ] 論文1の図表リストを整理する
- [ ] 論文2の非正則性証明を論文用に整形する
- [ ] 3P LogNormal 関連の国際文献を整理する
- [ ] AIC / 尤度 / L-moments への比較実験を最小限実施する

---

## メモ

- 論文1は「SLSC の一般論」として短く強くまとめる
- 論文2は「3P LogNormal 問題」に絞って実務的含意を出す
- 論文1で入れすぎると, 論文2の価値を食うので注意
