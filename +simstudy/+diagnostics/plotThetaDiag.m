function plotThetaDiag(src, gen, fit, N, varargin)
%PLOTTHETADIAG  Pairwise scatter + marginal QQ of estimated parameters.
%
%   simstudy.diagnostics.plotThetaDiag(src, gen, fit, N)
%   simstudy.diagnostics.plotThetaDiag(___, 'Metric', metricName)
%
%   src  : res 構造体 もしくは root フォルダ
%   gen  : generator model  (e.g. "gev")
%   fit  : fit model        (e.g. "gev")
%   N    : sample size      (e.g. 100)
%
%   Optional name-value
%     'ThetaList'  string array   → θ フィールドを指定（既定 = 全フィールド）
%
%   Example
%     res = simstudy.util.buildRes("results");
%     simstudy.diagnostics.plotThetaDiag(res,"gev","gev",100);
%

% -------- Parse -------------------------------------------------------
p = inputParser;
addParameter(p,'ThetaList',string.empty);
parse(p,varargin{:});
thSel = p.Results.ThetaList;

% -------- 取り出し ----------------------------------------------------
pair = gen + "2" + fit;
thetaArr = simstudy.util.getMetric(src, N, pair, "theta");  % returns struct array
if isempty(thetaArr)
    error("theta not found for %s N=%d", pair, N);
end

fn = fieldnames(thetaArr(1));
if ~isempty(thSel); fn = intersect(fn, thSel, 'stable'); end
k  = numel(fn);

% -------- 行列用データを作成 ----------------------------------------
M = zeros(numel(thetaArr), k);
for j = 1:k
    M(:,j) = [thetaArr.(fn{j})].';
end

% -------- 図: scatter matrix + QQ ------------------------------------
figure('Position',[100 100 400+150*k 400+150*k]);
tiledlayout(k,k,'TileSpacing','compact');

for r = 1:k
    for c = 1:k
        nexttile;
        if r == c          % QQ プロット
            qqplot(M(:,c));
            xlabel('Normal Q'); ylabel(fn{c});
            title('');
        else               % scatter
            scatter(M(:,c), M(:,r), 6, 'filled', 'MarkerFaceAlpha',0.1);
            xlabel(fn{c}); ylabel(fn{r});
        end
    end
end
sgtitle(sprintf('%s \\rightarrow %s   N=%d', gen, fit, N));
end