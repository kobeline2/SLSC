function vec = getMetric(src, N, pair, metric)
%GETMETRIC  Return metric vector for given (N, pair, metric).
%
%   vec = simstudy.util.getMetric(src, N, pair, metric)
%
%   src    : (a) structure  res  produced by buildRes
%            (b) root folder that contains  <pair>/aggregate.mat
%   N      : numeric    e.g. 50, 100, 150
%   pair   : string     "lgamma2exponential"
%   metric : string     "slsc" | "aic" | "xentropy" | …
%
%   The function first looks for  res.<pair>.<N##>.metrics.<metric>
%   then falls back to  res.<pair>.<N##>.<metric>  (legacy layout).
% 
% EXAMPLE:
% % res 構造体を渡す
% v = simstudy.util.getMetric(res, 100, "exponential2exponential", "slsc");
% フォルダを渡す（オンデマンド読み込み）
% v = simstudy.util.getMetric("results", 100, "exponential2exponential", "slsc");
% 

arguments
    src
    N          (1,1) double
    pair       string
    metric     string
end

fldN   = "N" + N;
metric = lower(metric);

% ---------------------------------------------------------------------
if isstruct(src)                                % -------- struct case
    try
        node = src.(pair).(fldN);
    catch
        error("getMetric:NoNode", "res.%s.%s not found.", pair, fldN);
    end

    if isfield(node, "metrics") && isfield(node.metrics, metric)
        vec = node.metrics.(metric);            % new layout
    elseif isfield(node, metric)
        vec = node.(metric);                    % legacy layout
    else
        error("getMetric:Missing", ...
              "Metric '%s' not found in res.%s.%s.", metric, pair, fldN);
    end

% ---------------------------------------------------------------------
else                                            % -------- folder case
    tagDir = sprintf("N%d_%s", N, pair);      % N50_lgamma2exponential
    agg    = fullfile(src, tagDir, "aggregate.mat");
    if ~isfile(agg)
        error("getMetric:NoFile", "%s not found.", agg);
    end

    S = load(agg, "allMetrics");
    if ~isfield(S.allMetrics, metric)
        error("getMetric:Missing", "'%s' not in %s.", metric, agg);
    end
    vec = S.allMetrics.(metric);
end
end