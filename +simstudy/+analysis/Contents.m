%% simstudy.analysis
% 可視化・統計サマリー関数をまとめたパッケージ
%
% 関数一覧
%   plotMetricViolin     - Violin-plot of <metric> vs N for a given (gen,fit) pair.
%   plotSLSCpassRateVar  - 可変しきい値で P(SLSC < τ) ヒートマップ
%
% 使い方例
%   res = load("results/allRes.mat").res;
%   th  = readtable("thresholds.csv");
%   simstudy.analysis.plotSLSC95(res);
