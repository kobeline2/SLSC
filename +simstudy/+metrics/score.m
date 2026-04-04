function val = score(metric, data, fitRes)
% Compute evaluation metrics for fitted distributions.
%
%   val = simstudy.metrics.score(metric, data, fitRes)
%
%   metric : char/string  – 'AIC', 'Xentropy', etc.
%   data   : numeric      – observed samples
%   fitRes : struct       – output from MLE(), contains .model .theta

arguments
    metric
    data  {mustBeNumeric}
    fitRes struct
end

metric  = upper(string(metric));
funcMap = containers.Map( ...
    {'AIC','XENTROPY','SLSC','SLSC_X'}, ...
    {@simstudy.metrics.AIC, ...
     @simstudy.metrics.Xentropy, ...
     @simstudy.metrics.SLSC, ...
     @simstudy.metrics.SLSC_x});

if ~funcMap.isKey(metric)
    error("simstudy:metrics","Unknown metric %s",metric);
end

f   = funcMap(metric);          % ここで function_handle を取得
val = f(data, fitRes);          % 評価
end
