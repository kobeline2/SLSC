% Load and preview one completed run directory under local/runs.
%
% Edit runLabel and tag as needed.

init();
paths = slscLocalPaths(false);

runLabel = "";
tag = "N50_gumbel2gumbel";

if strlength(runLabel) == 0
    runs = dir(paths.runsDir);
    runs = runs([runs.isdir]);
    runs = runs(~ismember({runs.name}, {'.', '..'}));
    if isempty(runs)
        error("No run directories found under %s", paths.runsDir);
    end
    [~, idx] = max([runs.datenum]);
    runLabel = string(runs(idx).name);
end

root = fullfile(paths.runsDir, runLabel);
S = simstudy.util.loadAggregate(root, tag);
raw = load(S.file, "exitflagArray", "runMeta");

disp("Loaded aggregate:");
disp(S.file);
disp(structfun(@mean, S.data, "UniformOutput", false));

if isfield(raw, "exitflagArray")
    okRate = mean(raw.exitflagArray > 0);
    fprintf("Exitflag > 0 rate: %.4f\n", okRate);
end

if isfield(raw, "runMeta")
    disp("Run metadata:");
    disp(raw.runMeta);
end
