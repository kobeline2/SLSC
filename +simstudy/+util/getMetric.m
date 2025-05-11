function vec = getMetric(src, N, pair, metric)
%GETMETRIC  Return the metric vector for a given (N, pair, metric).
%
%   vec = simstudy.util.getMetric(src, N, pair, metric)
%
%   src    : (a) structure  res.<pair>.N##.<metric>
%            (b) root folder that contains   <pair>/aggregate.mat
%   N      : numeric   (e.g. 50,100,150)
%   pair   : string    like "lgamma2exponential"
%   metric : string    "slsc" | "aic" | "xentropy" | ...
%
%   The function throws if the metric is missing.

fldN = "N" + N;
metric = lower(string(metric));

if isstruct(src)                                     % --- struct case
    try
        vec = src.(pair).(fldN).(metric);
    catch
        error("getMetric:Missing", "Metric '%s' not found in res.%s.%s.", ...
              metric, pair, fldN);
    end
else                                                 % --- folder case
    agg = fullfile(src, pair, "aggregate.mat");
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