function res = buildRes(root, varName)
%BUILDRES  Merge every aggregate.mat under <root> into a nested struct "res".
%
%   res = simstudy.util.buildRes(root)
%   res = simstudy.util.buildRes(root, varName)
%
%   root     : top folder   (contains <tag>/aggregate.mat)
%   varName  : variable holding the metrics in aggregate.mat
%              default = "allMetrics"
%
%   Output
%       res.<pair>.<N##>.metrics  = struct( slsc = vec, aic = vec, … )
%       res.<pair>.<N##>.theta    = 1×rep struct array   (if thetaArray exists)
%
%   Example
%       res = simstudy.util.buildRes("results");
%       v   = simstudy.util.getMetric(res, 50, "gumbel2gev", "slsc");

arguments
    root    string = "results"
    varName string = "allMetrics"
end

% ------------------------------------------------------------
files = dir(fullfile(root,"**","aggregate.mat"));
if isempty(files)
    error("buildRes:NoFile","No aggregate.mat under %s", root);
end

TAGPAT = 'N(\d+)_([^0-9]+)2(.+)';      % "N50_gumbel2gev"
res    = struct();

for k = 1:numel(files)
    % ---- tag parsing -----------------------------------------------
    tag = erase(files(k).folder, root + filesep);    % relative path
    tok = regexp(tag, TAGPAT, 'tokens', 'once');
    if isempty(tok), continue, end

    Nfld = "N" + tok{1};                             % e.g. "N50"
    pair = matlab.lang.makeValidName(tok{2} + "2" + tok{3});  % safe field

    % ---- load aggregate --------------------------------------------
    A = load(fullfile(files(k).folder, "aggregate.mat"), ...
             varName, "thetaArray");                 % try θ as well

    if ~isfield(A, varName)
        warning("%s missing variable '%s' – metrics skipped.", tag, varName);
        metricsData = struct();
    else
        metricsData = A.(varName);
    end

    if isfield(A, "thetaArray")
        thetaData = A.thetaArray;
    else
        thetaData = [];              % optional (old aggregates)
    end

    % ---- store into nested structure -------------------------------
    if ~isfield(res, pair), res.(pair) = struct(); end

    node          = struct();
    node.metrics  = metricsData;
    if ~isempty(thetaData)
        node.theta = thetaData;
    end

    res.(pair).(Nfld) = node;
end
end