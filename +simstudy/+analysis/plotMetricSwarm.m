function plotMetricSwarm(src, gen, fit, metric, Nlist, opts)
%PLOTMETRICVIOLIN  swarmchart of <metric> vs N for a given (gen,fit) pair.
%
%   simstudy.analysis.plotMetricSwarm(src, gen, fit, metric, Nlist)
%   simstudy.analysis.plotMetricSwarm(src, gen, fit, metric, Nlist, opts)
%
%   src     : res 構造体 あるいは root フォルダ ("results" など)
%   gen     : string   generator model   (e.g. "lgamma")
%   fit     : string   fit model         (e.g. "gev")
%   metric  : string   metric 名         
%   Nlist   : numeric array   サンプルサイズ [50 100 150] など
%
%   opts (name-value 引数)
%     'Quantiles' : double array in (0,1)   パーセンタイル線 (default = [0.1 0.5 0.9])
%     'ViolinArgs': cell array              violinplot への追加引数
%
%   依存:  swarmchart
%
%   例:
%     res  = simstudy.util.buildRes("results");
%     simstudy.analysis.plotMetricSwarm(res, "exponential", "gumbel", "slsc", [50 100 150], 'Quantiles', [0.05 0.5 0.95]);
%

arguments
    src
    gen           string
    fit           string
    metric        string
    Nlist         double   {mustBeVector}
    opts.Quantiles double  = [0.1 0.5 0.9]
end

pair = gen + "2" + fit;
qVec = opts.Quantiles(:)';

% ----- collect data ---------------------------------------------------
M = 1000;                                   % ← keep at most M points per N
dataCell = cell(numel(Nlist),1);

for i = 1:numel(Nlist)
    vec = simstudy.util.getMetric(src, Nlist(i), pair, metric).';
    n   = numel(vec);
    if n > M
        idx = randperm(n, M);               % ランダム間引き
        vec = vec(idx);
    end
    dataCell{i} = vec;
end


% ----- flatten to vector + grouping -----------------------------------
y      = vertcat(dataCell{:});                     % 全データ連結
y      = reshape(y', [], 1);
groups = repelem(Nlist(:), cellfun(@numel,dataCell)); % 同じ長さの数値ベクトル
groups = categorical(groups);                      % カテゴリに変換すると軸にNが表示

% ----- plot -----------------------------------------------------------
figure('Position',[100 100 600 400]);
swarmchart(groups, y, 8, 'filled', 'MarkerFaceAlpha',0.1);         % built-in / FEX 両対応
hold on;

% ----- quantile lines -------------------------------------------------

for i = 1:numel(Nlist)
    vfull = simstudy.util.getMetric(src, Nlist(i), pair, metric);
    for qi = 1:numel(qVec)
        tau = quantile(vfull, qVec(qi));
        plot([i-0.1 i+0.1], [tau tau], '-', ...
             'Color', 'r', 'LineWidth',2.4);
    end
end

% ----- cosmetic -------------------------------------------------------
xlabel('N'); ylabel(upper(metric));
% title(gen + " → " + fit + "   (" + upper(metric) + ")");
% legend(arrayfun(@(q) sprintf('%.0f%%',q*100), qVec, ...
%        'UniformOutput',false), 'Location','best');
% grid on; 
box on;
end