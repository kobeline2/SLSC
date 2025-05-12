function th = makeThreshold(res, q, metric)
%MAKETHRESHOLD  Build threshold table τ(N,model) from diagonal SLSC results.
%
%   th = simstudy.util.makeThreshold(res)
%   th = simstudy.util.makeThreshold(res, q)
%   th = simstudy.util.makeThreshold(res, q, metric)
%
%   Inputs
%       res    : structure from buildRes
%       q      : quantile in (0,1)   (default = 0.90)
%       metric : metric field name   (default = "slsc")
%
%   Output
%       th  : table
%               N     gen        fit     metric   value
%               __   ________   ______   ______   ______
%               50   "gev"      "gev"     slsc     …
%              100   "gumbel"   "gumbel"  slsc     …
%
%   Only pairs where gen and fit are identical are included.
% 
% Example
%   
%   res = simstudy.util.buildRes("results");   % metrics & theta を統合
%   th90 = simstudy.util.makeThreshold(res);           % 90% デフォルト
%   th95 = simstudy.util.makeThreshold(res, 0.95);     % 95% クオンタイル

arguments
    res    struct
    q      double {mustBeGreaterThan(q,0),mustBeLessThan(q,1)} = 0.90
    metric string = "slsc"
end

pairs = fieldnames(res);
rows  = [];

for p = 1:numel(pairs)
    pair = string(pairs{p});                 % e.g. "lgamma2lgamma"
    toks = split(pair,"2");
    if numel(toks)~=2 || toks(1)~=toks(2)    % gen ≠ fit → スキップ
        continue
    end
    model = toks(1);                         % "lgamma"
    Ns    = fieldnames(res.(pair));

    for n = 1:numel(Ns)
        Nstr = string(Ns{n});                % "N50"
        Nval = str2double(extractAfter(Nstr,"N"));

        if ~isfield(res.(pair).(Nstr).metrics, metric)
            warning("%s.%s missing metric '%s'", pair, Nstr, metric); continue
        end

        vec   = res.(pair).(Nstr).metrics.(metric);
        tau   = quantile(vec, q);

        rows  = [rows;
                 table(Nval, model, model, metric, tau, ...
                       'VariableNames',{'N','gen','fit','metric','value'})];
    end
end

% sort for readability
th = sortrows(rows, {'N','gen'});
end