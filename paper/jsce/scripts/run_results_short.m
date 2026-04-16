function out = run_results_short(arg)
%RUN_RESULTS_SHORT Run the short JSCE setup or rebuild figures.
%
%   out = run_results_short()
%       Run N = [50 100 150], rep = 100.
%
%   out = run_results_short(summaryPath)
%       Rebuild both figures from an existing summary MAT.
%
%   out = run_results_short(opts)
%       Run with a user-supplied options struct, based on the short setup.

if nargin == 0
    out = run_results_custom(localShortDefaults(struct()));
    return;
end

if isstruct(arg)
    out = run_results_custom(localShortDefaults(arg));
    return;
end

summaryPath = string(arg);
if strlength(summaryPath) == 0
    summaryPath = fullfile(localFigureDir(), "results_summary_short.mat");
end

S = load(summaryPath, "summary", "cfg", "runRoot");
summary = S.summary;
summary.labels = localLabels(summary.models);
summary.table1 = localBuildRelativeTable(summary);
summary.table2 = localBuildSelectionTable(summary);

cfg = [];
if isfield(S, "cfg")
    cfg = S.cfg;
end
runRoot = "";
if isfield(S, "runRoot")
    runRoot = string(S.runRoot);
end
save(summaryPath, "summary", "cfg", "runRoot");

fig1Path = fullfile(localFigureDir(), "slsc_n_scaling_panels.pdf");
fig2Path = fullfile(localFigureDir(), "criterion_compare.pdf");
make_slsc_n_scaling_figure(summaryPath, fig1Path);
make_criterion_compare_figure(summaryPath, fig2Path);

localPrintTablePreview(summary);

out = struct();
out.runRoot = runRoot;
out.summaryPath = summaryPath;
out.figurePaths = struct( ...
    "slscScaling", string(fig1Path), ...
    "criterionCompare", string(fig2Path));
out.table1 = summary.table1;
out.table2 = summary.table2;
end

function opts = localShortDefaults(opts)
if nargin < 1
    opts = struct();
end

defaults = struct();
defaults.models = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
defaults.Nlist = [50, 100, 150];
defaults.rep = 100;
defaults.metrics = {'SLSC', 'SLSC_X', 'AIC'};
defaults.slscProfile = "japan_admin";
defaults.runLabelPrefix = "paper_jsce_short";
defaults.summaryFilename = "results_summary_short.mat";
defaults.scalingFigureFilename = "slsc_n_scaling_panels.pdf";
defaults.criterionFigureFilename = "criterion_compare.pdf";
defaults.makeFigures = true;

keys = fieldnames(defaults);
for i = 1:numel(keys)
    key = keys{i};
    if ~isfield(opts, key)
        opts.(key) = defaults.(key);
    end
end
end

function table1 = localBuildRelativeTable(summary)
models = string(summary.models);
labels = string(localLabels(summary.models));
ln3Idx = find(models == "lnormal", 1);
G = numel(models);
K = numel(summary.Nlist);
hasLn3 = ~isempty(ln3Idx);

table1 = struct();
table1.rowLabels = labels;
if hasLn3
    table1.colLabels = [labels(models ~= "lnormal"), "LN3(X)", "LN3(S)"];
else
    table1.colLabels = labels;
end
table1.values = NaN(G, numel(table1.colLabels));

keepModels = models;
if hasLn3
    keepModels = models(models ~= "lnormal");
end

col = 1;
for m = keepModels
    fi = find(models == m, 1);
    for gi = 1:G
        ratios = NaN(1, K);
        for ni = 1:K
            denom = summary.stats.slsc_x.mean(gi, gi, ni);
            numer = summary.stats.slsc_x.mean(gi, fi, ni);
            ratios(ni) = numer / denom;
        end
        table1.values(gi, col) = mean(ratios, "omitnan");
    end
    col = col + 1;
end

if hasLn3
    for gi = 1:G
        ratiosX = NaN(1, K);
        ratiosS = NaN(1, K);
        for ni = 1:K
            denom = summary.stats.slsc_x.mean(gi, gi, ni);
            ratiosX(ni) = summary.stats.slsc_x.mean(gi, ln3Idx, ni) / denom;
            ratiosS(ni) = summary.stats.slsc.mean(gi, ln3Idx, ni) / denom;
        end
        table1.values(gi, end-1) = mean(ratiosX, "omitnan");
        table1.values(gi, end) = mean(ratiosS, "omitnan");
    end
end
end

function table2 = localBuildSelectionTable(summary)
table2 = struct();
table2.rowLabels = string(localLabels(summary.models));
table2.colLabels = ["X-space SLSC", "S-space SLSC", "AIC"];
table2.values = [ ...
    mean(summary.selection.slsc_x, 2, "omitnan"), ...
    mean(summary.selection.slsc, 2, "omitnan"), ...
    mean(summary.selection.aic, 2, "omitnan")];
end

function localPrintTablePreview(summary)
disp("Table 1 preview (relative SLSC, averaged over N values):");
localPrintTable(summary.table1, true);
disp("Table 2 preview (true-model selection rate, averaged over N values):");
localPrintTable(summary.table2, false);
end

function localPrintTable(tbl, highlightBelowOne)
header = "sampler";
for c = 1:numel(tbl.colLabels)
    header = header + sprintf("\t%s", tbl.colLabels(c));
end
disp(header);

for r = 1:numel(tbl.rowLabels)
    lineText = tbl.rowLabels(r);
    for c = 1:numel(tbl.colLabels)
        val = tbl.values(r, c);
        token = sprintf("%.3f", val);
        if highlightBelowOne && val < 1 - 1e-12
            token = "[" + token + "]";
        end
        lineText = lineText + sprintf("\t%s", token);
    end
    disp(lineText);
end
end

function labels = localLabels(models)
models = string(models);
labels = strings(size(models));
for i = 1:numel(models)
    switch models(i)
        case "gumbel"
            labels(i) = "Gumbel";
        case "gev"
            labels(i) = "GEV";
        case "lgamma"
            labels(i) = "LP3";
        case "sqrtet"
            labels(i) = "SqrtEt";
        case "exponential"
            labels(i) = "Exp";
        case "lnormal"
            labels(i) = "LN3";
        otherwise
            labels(i) = models(i);
    end
end
end

function figDir = localFigureDir()
scriptPath = mfilename("fullpath");
scriptsDir = fileparts(scriptPath);
jsceDir = fileparts(scriptsDir);
figDir = fullfile(jsceDir, "fig", "results");
if ~isfolder(figDir)
    mkdir(figDir);
end
end
