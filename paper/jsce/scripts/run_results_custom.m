function out = run_results_custom(opts)
%RUN_RESULTS_CUSTOM Run the JSCE paper experiment with editable settings.
%
% This file is intentionally self-contained.
% Edit the block near the top, then run:
%   out = run_results_custom()
%   out = run_results_custom(opts)

if nargin < 1
    opts = struct();
end

% ----- Edit here -------------------------------------------------------
defaultOpts = struct();
defaultOpts.models = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
defaultOpts.Nlist = [50, 100, 150];
defaultOpts.rep = 100;
defaultOpts.metrics = {'SLSC', 'SLSC_X', 'AIC'};
defaultOpts.slscProfile = "japan_admin";
defaultOpts.runLabelPrefix = "paper_jsce_custom";
defaultOpts.summaryFilename = "results_summary_custom.mat";
defaultOpts.scalingFigureFilename = "slsc_n_scaling_custom.pdf";
defaultOpts.criterionFigureFilename = "criterion_compare_custom.pdf";
defaultOpts.makeFigures = true;
% ----------------------------------------------------------------------

init();
opts = localFillDefaults(opts, defaultOpts);

paths = slscLocalPaths(true);
runLabel = opts.runLabelPrefix + "_" + ...
    string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runRoot = fullfile(paths.runsDir, runLabel);
mkdir(runRoot);

cfg = simstudy.config.base();
cfg.genList = opts.models;
cfg.fitList = opts.models;
cfg.Nlist = opts.Nlist;
cfg.rep = opts.rep;
cfg.metrics = opts.metrics;
cfg.slscProfile = opts.slscProfile;
cfg.rawDirRoot = runRoot;

fprintf("Running paper results into %s\n", runRoot);
experiments.runBatch(cfg);

summary = localBuildSummary(runRoot, cfg);
summary = localDecorateSummary(summary);

figureDir = localFigureDir();
summaryPath = fullfile(figureDir, opts.summaryFilename);
save(summaryPath, "summary", "cfg", "runRoot");

fig1Path = fullfile(figureDir, opts.scalingFigureFilename);
fig2Path = fullfile(figureDir, opts.criterionFigureFilename);
if opts.makeFigures
    make_slsc_n_scaling_figure(summaryPath, fig1Path);
    make_criterion_compare_figure(summaryPath, fig2Path);
end

localPrintTablePreview(summary);

out = struct();
out.runRoot = string(runRoot);
out.summaryPath = string(summaryPath);
out.figurePaths = struct( ...
    "slscScaling", string(fig1Path), ...
    "criterionCompare", string(fig2Path));
out.table1 = summary.table1;
out.table2 = summary.table2;
end

function opts = localFillDefaults(opts, defaultOpts)
keys = fieldnames(defaultOpts);
for i = 1:numel(keys)
    key = keys{i};
    if ~isfield(opts, key)
        opts.(key) = defaultOpts.(key);
    end
end
opts.models = string(opts.models);
opts.Nlist = double(opts.Nlist(:)).';
end

function summary = localBuildSummary(runRoot, cfg)
models = string(cfg.genList);
Nlist = double(cfg.Nlist(:)).';
G = numel(models);
F = numel(models);
K = numel(Nlist);
metrics = ["slsc", "slsc_x", "aic"];

summary = struct();
summary.models = models;
summary.labels = localLabels(models);
summary.Nlist = Nlist;
summary.rep = cfg.rep;
summary.runRoot = string(runRoot);
summary.metricNames = metrics;
summary.stats = struct();
summary.selection = struct();

for mi = 1:numel(metrics)
    metric = metrics(mi);
    summary.stats.(metric) = struct( ...
        "mean", NaN(G, F, K), ...
        "std", NaN(G, F, K), ...
        "validRate", NaN(G, F, K));
    summary.selection.(metric) = NaN(G, K);
end

for gi = 1:G
    gen = models(gi);
    trueIdx = gi;

    for ni = 1:K
        N = Nlist(ni);
        metricMatrix = struct();
        validMatrix = false(cfg.rep, F);
        for mi = 1:numel(metrics)
            metricMatrix.(metrics(mi)) = NaN(cfg.rep, F);
        end

        for fi = 1:F
            fit = models(fi);
            tag = sprintf("N%d_%s2%s", N, gen, fit);
            aggPath = fullfile(runRoot, tag, "aggregate.mat");
            S = load(aggPath, "allMetrics", "exitflagArray");

            valid = true(numel(S.allMetrics.(metrics(1))), 1);
            if isfield(S, "exitflagArray")
                valid = S.exitflagArray > 0;
            end
            validMatrix(:, fi) = valid(:);

            for mi = 1:numel(metrics)
                metric = metrics(mi);
                vals = S.allMetrics.(metric);
                vals = vals(:);
                goodVals = vals(valid);
                summary.stats.(metric).mean(gi, fi, ni) = mean(goodVals, "omitnan");
                summary.stats.(metric).std(gi, fi, ni) = std(goodVals, 0, "omitnan");
                summary.stats.(metric).validRate(gi, fi, ni) = mean(valid);
                metricMatrix.(metric)(:, fi) = vals;
            end
        end

        for mi = 1:numel(metrics)
            metric = metrics(mi);
            M = metricMatrix.(metric);
            M(~validMatrix) = inf;
            M(~isfinite(M)) = inf;
            hasFinite = any(isfinite(M), 2);
            [~, idx] = min(M(hasFinite, :), [], 2);
            summary.selection.(metric)(gi, ni) = mean(idx == trueIdx);
        end
    end
end
end

function summary = localDecorateSummary(summary)
summary.labels = localLabels(summary.models);
summary.table1 = localBuildRelativeTable(summary);
summary.table2 = localBuildSelectionTable(summary);
end

function table1 = localBuildRelativeTable(summary)
models = string(summary.models);
labels = string(summary.labels);
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
table2.rowLabels = string(summary.labels);
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
            labels(i) = "P3";
        case "lp3"
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
