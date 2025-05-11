function res = buildRes(root, varName)
%BUILDRES  Collect every aggregate.mat into a unified struct "res".
%
%   res = simstudy.util.buildRes(root)
%   res = simstudy.util.buildRes(root, varName)
%
%   root    : folder that contains tag sub-dirs   N50_gumbel2gev/aggregate.mat …
%   varName : variable to load from aggregate.mat   (default = 'allMetrics')
%
%   Output
%       res.<pair>.<N##> = struct( slsc = vec, aic = vec, … )
%
%   Example
%     res = simstudy.util.buildRes("results");
%
%   After that you can call
%     vec = simstudy.util.getMetric(res, 50, "gumbel2gev", "slsc");

arguments
    root   string = "results"
    varName string = "allMetrics"
end

files = dir(fullfile(root,"**","aggregate.mat"));
if isempty(files), error("buildRes:NoFile","No aggregate.mat under %s",root); end

TAGPAT = 'N(\d+)_([^0-9]+)2(.+)';   % N50_gumbel2gev
res    = struct();

for k = 1:numel(files)
    tag = erase(files(k).folder, root+filesep);    % relative path
    tok = regexp(tag, TAGPAT, 'tokens','once');
    if isempty(tok), continue, end

    Nfld  = "N"+tok{1};                % N50
    pair  = matlab.lang.makeValidName(tok{2} + "2" + tok{3});  % safe field

    S = load(fullfile(files(k).folder,"aggregate.mat"), varName);
    if ~isfield(S, varName), warning("%s missing %s",tag,varName); continue, end

    % --- build nested struct ----------------------------------------
    if ~isfield(res, pair), res.(pair) = struct(); end
    res.(pair).(Nfld) = S.(varName);
end
end