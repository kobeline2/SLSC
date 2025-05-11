%% simstudy.analysis
% 可視化・統計サマリー関数をまとめたパッケージ
%
% 関数一覧
%   plotSLSC95           - N ごとの SLSC 95 % 分位を描画
%   plotSLSCpassRateVar  - 可変しきい値で P(SLSC < τ) ヒートマップ
%
% 使い方例
%   res = load("results/allRes.mat").res;
%   th  = readtable("thresholds.csv");
%   simstudy.analysis.plotSLSC95(res);
