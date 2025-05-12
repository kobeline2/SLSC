function plotSLSCpassRateVar(src, th, opts)
%PLOTSLSCPASSRATEVAR  Heat-map(s) of the pass-rate P(metric < τ).
%
%   ── PURPOSE ──────────────────────────────────────────────────────────
%     For every combination of generator-model (row) and fit-model
%     (column) this function computes
%
%           pass-rate =  mean( metric  <  τ(N, fit) )
%
%     and displays the values as colour-coded heat-maps, one per sample
%     size N.
%
%   ── BASIC CALLS ──────────────────────────────────────────────────────
%     1) Fixed threshold τ = 0.04 for all N & fit
%        >> plotSLSCPASSRATEVAR(res)
%
%     2) Variable threshold table τ(N,fit)    (see example below)
%        >> plotSLSCPASSRATEVAR(res, th)
%           c.f. th  = simstudy.util.makeThreshold(res, 0.90);
%
%     3) Folder mode (no res in memory) + custom options
%        >> plotSLSCPASSRATEVAR("results", th, ...
%              'genList', ["gev","gumbel","lgamma"], ...
%              'Nlist',   [50 100])
%
%   ── INPUTS ──────────────────────────────────────────────────────────
%     src   : 1) structure `res` produced by buildRes,      OR
%             2) string/char root folder that contains
%                <tag>/aggregate.mat   (on-demand loading)
%
%     th    : table with columns     N , fit , value
%                 N    : double      (sample size, e.g. 50)
%                 fit  : string      (fit-model name, e.g. "gev")
%                 value: double      (threshold τ)
%             *If omitted or empty ([]), the constant τ = 0.04 is used.*
%
%     Name-value options (all optional):
%       'genList' : string array   generator models   (default listed below)
%       'fitList' : string array   fit models         (default = genList)
%       'Nlist'   : numeric array  sample sizes       (default = [50 100 150])
%       'metric'  : string         metric field name  (default = "slsc")
%
%       Example — name-value syntax
%          plotSLSCPASSRATEVAR(res, [], ...
%                'metric', 'aic', ...
%                'genList', ["gev","gumbel"]);
%
%   ── DEFAULT MODEL ORDER ─────────────────────────────────────────────
%     ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"]
%
%   ── THRESHOLD TABLE EXAMPLE ─────────────────────────────────────────
%       >> th = table([50;50;50;100;100;100], ...
%                     ["gev";"gumbel";"lgamma";"gev";"gumbel";"lgamma"], ...
%                     0.04*[1.2;1.1;1.0;0.9;0.8;0.7], ...
%                     'VariableNames',{'N','fit','value'});
%
%   ── OUTPUT ──────────────────────────────────────────────────────────
%     A figure window containing one heat-map per N.
%     • Rows   = generator models (genList)
%     • Columns= fit models       (fitList)
%     • Cell   = proportion in (0,1); numbers are also printed
%
%   ── DEPENDENCIES ────────────────────────────────────────────────────
%     * simstudy.util.getMetric
%   ─────────────────────────────────────────────────────────────────────

arguments
    src
    th table = table()                         % τ = 0.04 if empty
    opts.genList string = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"]
    opts.fitList string = string.empty         % ← いったん空に
    opts.Nlist   double = [50 100 150]
    opts.metric  string = "slsc"
end
% ---- fill default for fitList ----------------------------------------
if isempty(opts.fitList)
    opts.fitList = opts.genList;               % genList と同じに統一
end

genList = opts.genList(:);
fitList = opts.fitList(:);
Nlist   = opts.Nlist(:);
metric  = lower(opts.metric);

figure('Position',[100 100 320*numel(Nlist) 360]);

for nIdx = 1:numel(Nlist)
    N = Nlist(nIdx);
    M = nan(numel(genList), numel(fitList));

    for gi = 1:numel(genList)
        for fi = 1:numel(fitList)
            pair = genList(gi) + "2" + fitList(fi);

            % ---------- τ(N,fit) の決定 ------------------------------
            if isempty(th)
                tau = 0.04;                         % デフォルト閾値
            else
                idx = th.N == N & th.fit == fitList(fi);
                tau = 0.04;
                if any(idx)
                    tau = th.value(find(idx,1,'first'));
                end
            end

            % ---------- メトリクス取得 -------------------------------
            try
                vec = simstudy.util.getMetric(src, N, pair, metric);
                M(gi,fi) = mean(vec < tau);
            catch
                % データ欠損は NaN (既定色)
            end
        end
    end

    % ---------- 描画 -----------------------------------------------
    subplot(1,numel(Nlist), nIdx);
    h = heatmap(fitList, genList, M, ...
                'Colormap', turbo, 'ColorLimits',[0 1], ...
                'MissingDataColor',[0.85 0.85 0.85], ...
                'CellLabelFormat','%.2f');
    title("N = " + N); xlabel("fit"); ylabel("gen");
end

sgtitle("Pass rate   P(" + upper(metric) + " < τ(N, fit))");
end