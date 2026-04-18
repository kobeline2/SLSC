function out = run_criterion_compare(opts)
%RUN_CRITERION_COMPARE Compute SLSC+jackknife and AIC selection results.
%
% This file is intentionally self-contained for the JSCE paper.
% Edit the block near the top, then run:
%   out = run_criterion_compare()
%   out = run_criterion_compare(opts)

if nargin < 1
    opts = struct();
end

% ----- Edit here -------------------------------------------------------
defaultOpts = struct();
defaultOpts.models = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
defaultOpts.Nlist = [50, 100, 150];
defaultOpts.rep = 100;
defaultOpts.seed = 42;
defaultOpts.slscThreshold = 0.04;
defaultOpts.Tref = 100;
defaultOpts.slscProfile = "japan_admin";
defaultOpts.slscTransforms = struct();
defaultOpts.runLabelPrefix = "criterion_compare";
defaultOpts.summaryFilename = "criterion_compare_summary.mat";
defaultOpts.selectionCsvFilename = "criterion_selection_rates.csv";
defaultOpts.pairMeansCsvFilename = "criterion_pair_means.csv";
defaultOpts.tableTexFilename = "criterion_selection_table.tex";
defaultOpts.figureFilename = "criterion_compare.pdf";
defaultOpts.useParallel = true;
defaultOpts.makeFigure = true;
% ----------------------------------------------------------------------

init();
opts = localFillDefaults(opts, defaultOpts);

paperRoot = localPaperRoot();
outDir = fullfile(paperRoot, "out");
figDir = fullfile(paperRoot, "fig", "results");
detailRoot = fullfile(outDir, "criterion_compare_runs");
if ~isfolder(outDir), mkdir(outDir); end
if ~isfolder(figDir), mkdir(figDir); end
if ~isfolder(detailRoot), mkdir(detailRoot); end

runLabel = opts.runLabelPrefix + "_" + string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runDir = fullfile(detailRoot, runLabel);
mkdir(runDir);

cfg = simstudy.config.base();
cfg.seed = opts.seed;
cfg.genList = cellstr(opts.models);
cfg.fitList = cellstr(opts.models);
cfg.Nlist = opts.Nlist;
cfg.rep = opts.rep;
cfg.slscProfile = opts.slscProfile;
cfg.slscTransforms = opts.slscTransforms;

tasks = localBuildTasks(opts.models, opts.Nlist);
taskCells = cell(numel(tasks), 1);

fprintf("Running criterion comparison into %s\n", runDir);
fprintf("Models : %s\n", strjoin(cellstr(localLabels(opts.models)), ", "));
fprintf("N list : %s\n", num2str(opts.Nlist));
fprintf("rep    : %d\n", opts.rep);
fprintf("Tref   : %g\n", opts.Tref);

if opts.useParallel && numel(tasks) > 1
    parfor ti = 1:numel(tasks)
        taskCells{ti} = localRunTask(tasks(ti), cfg, opts, runDir);
    end
else
    for ti = 1:numel(tasks)
        taskCells{ti} = localRunTask(tasks(ti), cfg, opts, runDir);
    end
end

summary = localBuildSummary(taskCells, opts, runDir);

summaryPath = fullfile(outDir, opts.summaryFilename);
selectionCsvPath = fullfile(outDir, opts.selectionCsvFilename);
pairMeansCsvPath = fullfile(outDir, opts.pairMeansCsvFilename);
tableTexPath = fullfile(outDir, opts.tableTexFilename);
figurePath = fullfile(figDir, opts.figureFilename);

save(summaryPath, "summary", "opts", "runDir");

selectionTable = localBuildSelectionRateTable(summary);
pairMeansTable = localBuildPairMeansTable(summary);
summaryTable = localBuildSummaryTable(summary);

writetable(selectionTable, selectionCsvPath);
writetable(pairMeansTable, pairMeansCsvPath);
localWriteSelectionTableTex(summaryTable, tableTexPath);

if opts.makeFigure
    plot_criterion_compare(summaryPath, figurePath);
end

out = struct();
out.runDir = string(runDir);
out.summaryPath = string(summaryPath);
out.selectionCsvPath = string(selectionCsvPath);
out.pairMeansCsvPath = string(pairMeansCsvPath);
out.tableTexPath = string(tableTexPath);
out.figurePath = string(figurePath);
out.summary = summary;
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
opts.rep = double(opts.rep);
opts.seed = double(opts.seed);
opts.slscThreshold = double(opts.slscThreshold);
opts.Tref = double(opts.Tref);
end

function tasks = localBuildTasks(models, Nlist)
G = numel(models);
K = numel(Nlist);
tasks = repmat(struct( ...
    "taskIdx", 0, ...
    "genIdx", 0, ...
    "NIdx", 0, ...
    "gen", "", ...
    "N", 0), G * K, 1);

ti = 1;
for gi = 1:G
    for ni = 1:K
        tasks(ti).taskIdx = ti;
        tasks(ti).genIdx = gi;
        tasks(ti).NIdx = ni;
        tasks(ti).gen = string(models(gi));
        tasks(ti).N = double(Nlist(ni));
        ti = ti + 1;
    end
end
end

function task = localRunTask(taskInfo, cfg, opts, runDir)
models = opts.models;
F = numel(models);
R = opts.rep;
gen = taskInfo.gen;
N = taskInfo.N;
trueIdx = taskInfo.genIdx;

task = struct();
task.gen = gen;
task.genIdx = taskInfo.genIdx;
task.N = N;
task.NIdx = taskInfo.NIdx;
task.models = models;
task.substream = zeros(R, 1);
task.slsc = NaN(R, F);
task.aic = NaN(R, F);
task.wj = NaN(R, F);
task.p0 = NaN(R, F);
task.aicValid = false(R, F);
task.slscValid = false(R, F);
task.jkValid = false(R, F);
task.exitflag = NaN(R, F);
task.selectedAIC = NaN(R, 1);
task.selectedSLSCJK = NaN(R, 1);
task.noPass = false(R, 1);
task.trueIdx = trueIdx;

for r = 1:R
    substream = (taskInfo.taskIdx - 1) * R + r;
    task.substream(r) = substream;

    rs = RandStream("Threefry", "Seed", cfg.seed);
    rs.Substream = substream;
    RandStream.setGlobalStream(rs);
    genKey = char(gen);
    obs = simstudy.distributions.rnd(genKey, N, cfg.trueParams.(genKey));
    obs = obs(:);

    for fi = 1:F
        fit = models(fi);
        [fitRes, fitStats] = localEvaluateFullFit(obs, fit, cfg, opts);

        task.slsc(r, fi) = fitStats.slsc;
        task.aic(r, fi) = fitStats.aic;
        task.p0(r, fi) = fitStats.p0;
        task.aicValid(r, fi) = fitStats.aicValid;
        task.slscValid(r, fi) = fitStats.slscValid;
        task.exitflag(r, fi) = fitStats.exitflag;

        if fitStats.p0Valid
            [wj, jkValid] = localJackknifeWidth(obs, fit, fitRes.theta, cfg, opts);
            task.wj(r, fi) = wj;
            task.jkValid(r, fi) = jkValid;
        end
    end

    task.selectedAIC(r) = localSelectMin(task.aic(r, :), task.aicValid(r, :));

    passMask = task.slscValid(r, :) & task.jkValid(r, :) & ...
        isfinite(task.slsc(r, :)) & (task.slsc(r, :) <= opts.slscThreshold);
    task.noPass(r) = ~any(passMask);

    if any(passMask)
        candMask = passMask;
    else
        candMask = task.jkValid(r, :) & isfinite(task.wj(r, :));
    end
    task.selectedSLSCJK(r) = localSelectMin(task.wj(r, :), candMask);
end

taskFile = fullfile(runDir, sprintf("N%d_%s.mat", N, gen));
save(taskFile, "task", "opts");
task.file = string(taskFile);
fprintf("Finished N=%d, gen=%s -> %s\n", N, gen, taskFile);
end

function [fitRes, stats] = localEvaluateFullFit(obs, fit, cfg, opts)
fitKey = char(string(fit));
fitRes = struct("theta", struct());
stats = struct();
stats.slsc = NaN;
stats.aic = NaN;
stats.p0 = NaN;
stats.aicValid = false;
stats.slscValid = false;
stats.p0Valid = false;
stats.exitflag = NaN;

try
    fitRes = simstudy.estimators.MLE(fitKey, obs, cfg.theta0.(fitKey));
    fitRes = localAttachSlscConfig(fitRes, opts, fit);
    stats.exitflag = fitRes.exitflag;

    if localValidExitflag(fitRes.exitflag) && isfinite(fitRes.loglik)
        stats.aic = localAICFromFitRes(fitRes);
        stats.aicValid = isfinite(stats.aic);
    end

    try
        stats.slsc = simstudy.metrics.score("SLSC", obs, fitRes);
    catch
        stats.slsc = NaN;
    end
    stats.slscValid = localValidExitflag(fitRes.exitflag) && isfinite(stats.slsc);

    try
        stats.p0 = simstudy.distributions.icdf(fitKey, localPRef(opts.Tref), fitRes.theta);
    catch
        stats.p0 = NaN;
    end
    stats.p0Valid = localValidExitflag(fitRes.exitflag) && isfinite(stats.p0);
catch
    fitRes = struct("theta", cfg.theta0.(fitKey));
end
end

function fitRes = localAttachSlscConfig(fitRes, opts, fit)
fitRes.slscProfile = string(opts.slscProfile);

if isstruct(opts.slscTransforms)
    key = char(string(fit));
    if isfield(opts.slscTransforms, key)
        fitRes.slscTransformVariant = string(opts.slscTransforms.(key));
    end
end
end

function [wj, ok] = localJackknifeWidth(obs, fit, thetaInit, cfg, opts)
fitKey = char(string(fit));
N = numel(obs);
pj = NaN(N, 1);
ok = true;

for j = 1:N
    obsMinus = obs;
    obsMinus(j) = [];
    try
        fitRes = simstudy.estimators.MLE(fitKey, obsMinus, thetaInit);
        if ~localValidExitflag(fitRes.exitflag)
            ok = false;
            break;
        end
        pj(j) = simstudy.distributions.icdf(fitKey, localPRef(opts.Tref), fitRes.theta);
        if ~isfinite(pj(j))
            ok = false;
            break;
        end
    catch
        ok = false;
        break;
    end
end

if ~ok || any(~isfinite(pj))
    wj = NaN;
    return;
end

pbar = mean(pj);
sP = sqrt(mean((pj - pbar).^2));
wj = sqrt(N - 1) * sP;
ok = isfinite(wj);
end

function idx = localSelectMin(values, validMask)
idx = NaN;
if ~any(validMask)
    return;
end

masked = inf(size(values));
masked(validMask) = values(validMask);
[~, idx] = min(masked);
end

function tf = localValidExitflag(flag)
tf = ~isempty(flag) && isfinite(flag) && (flag > 0);
end

function aic = localAICFromFitRes(fitRes)
k = numel(fieldnames(fitRes.theta));
aic = -2 * fitRes.loglik + 2 * k;
end

function p = localPRef(Tref)
p = 1 - 1 ./ Tref;
end

function summary = localBuildSummary(taskCells, opts, runDir)
models = opts.models;
labels = localLabels(models);
Nlist = opts.Nlist;
G = numel(models);
F = numel(models);
K = numel(Nlist);

summary = struct();
summary.models = models;
summary.labels = labels;
summary.Nlist = Nlist;
summary.rep = opts.rep;
summary.seed = opts.seed;
summary.Tref = opts.Tref;
summary.slscThreshold = opts.slscThreshold;
summary.runDir = string(runDir);
summary.selection = struct();
summary.selection.slsc_jk = NaN(G, K);
summary.selection.aic = NaN(G, K);
summary.selection.no_pass = NaN(G, K);
summary.pairMeans = struct();
summary.pairMeans.slsc = NaN(G, F, K);
summary.pairMeans.wj = NaN(G, F, K);
summary.pairMeans.aic = NaN(G, F, K);
summary.pairMeans.slscValidRate = NaN(G, F, K);
summary.pairMeans.wjValidRate = NaN(G, F, K);
summary.pairMeans.aicValidRate = NaN(G, F, K);
summary.taskFiles = strings(G, K);

for ti = 1:numel(taskCells)
    task = taskCells{ti};
    gi = task.genIdx;
    ni = task.NIdx;
    summary.selection.slsc_jk(gi, ni) = mean(task.selectedSLSCJK == task.trueIdx);
    summary.selection.aic(gi, ni) = mean(task.selectedAIC == task.trueIdx);
    summary.selection.no_pass(gi, ni) = mean(task.noPass);
    summary.pairMeans.slsc(gi, :, ni) = mean(task.slsc, 1, "omitnan");
    summary.pairMeans.wj(gi, :, ni) = mean(task.wj, 1, "omitnan");
    summary.pairMeans.aic(gi, :, ni) = mean(task.aic, 1, "omitnan");
    summary.pairMeans.slscValidRate(gi, :, ni) = mean(task.slscValid, 1);
    summary.pairMeans.wjValidRate(gi, :, ni) = mean(task.jkValid, 1);
    summary.pairMeans.aicValidRate(gi, :, ni) = mean(task.aicValid, 1);
    summary.taskFiles(gi, ni) = task.file;
end
end

function tbl = localBuildSelectionRateTable(summary)
rows = numel(summary.models) * numel(summary.Nlist) * 2;

Ncol = NaN(rows, 1);
genCol = strings(rows, 1);
genLabelCol = strings(rows, 1);
criterionCol = strings(rows, 1);
rateCol = NaN(rows, 1);
noPassCol = NaN(rows, 1);

ri = 1;
for gi = 1:numel(summary.models)
    for ni = 1:numel(summary.Nlist)
        Ncol(ri) = summary.Nlist(ni);
        genCol(ri) = summary.models(gi);
        genLabelCol(ri) = summary.labels(gi);
        criterionCol(ri) = "AIC";
        rateCol(ri) = summary.selection.aic(gi, ni);
        noPassCol(ri) = NaN;
        ri = ri + 1;

        Ncol(ri) = summary.Nlist(ni);
        genCol(ri) = summary.models(gi);
        genLabelCol(ri) = summary.labels(gi);
        criterionCol(ri) = "SLSC_JK";
        rateCol(ri) = summary.selection.slsc_jk(gi, ni);
        noPassCol(ri) = summary.selection.no_pass(gi, ni);
        ri = ri + 1;
    end
end

tbl = table(Ncol, genCol, genLabelCol, criterionCol, rateCol, noPassCol, ...
    'VariableNames', {'N', 'gen', 'gen_label', 'criterion', ...
    'true_selection_rate', 'no_pass_rate'});
end

function tbl = localBuildPairMeansTable(summary)
G = numel(summary.models);
F = numel(summary.models);
K = numel(summary.Nlist);
rows = G * F * K;

Ncol = NaN(rows, 1);
genCol = strings(rows, 1);
genLabelCol = strings(rows, 1);
fitCol = strings(rows, 1);
fitLabelCol = strings(rows, 1);
meanSlscCol = NaN(rows, 1);
meanWjCol = NaN(rows, 1);
meanAicCol = NaN(rows, 1);
slscValidRateCol = NaN(rows, 1);
wjValidRateCol = NaN(rows, 1);
aicValidRateCol = NaN(rows, 1);

ri = 1;
for gi = 1:G
    for fi = 1:F
        for ni = 1:K
            Ncol(ri) = summary.Nlist(ni);
            genCol(ri) = summary.models(gi);
            genLabelCol(ri) = summary.labels(gi);
            fitCol(ri) = summary.models(fi);
            fitLabelCol(ri) = summary.labels(fi);
            meanSlscCol(ri) = summary.pairMeans.slsc(gi, fi, ni);
            meanWjCol(ri) = summary.pairMeans.wj(gi, fi, ni);
            meanAicCol(ri) = summary.pairMeans.aic(gi, fi, ni);
            slscValidRateCol(ri) = summary.pairMeans.slscValidRate(gi, fi, ni);
            wjValidRateCol(ri) = summary.pairMeans.wjValidRate(gi, fi, ni);
            aicValidRateCol(ri) = summary.pairMeans.aicValidRate(gi, fi, ni);
            ri = ri + 1;
        end
    end
end

tbl = table(Ncol, genCol, genLabelCol, fitCol, fitLabelCol, ...
    meanSlscCol, meanWjCol, meanAicCol, ...
    slscValidRateCol, wjValidRateCol, aicValidRateCol, ...
    'VariableNames', {'N', 'gen', 'gen_label', 'fit', 'fit_label', ...
    'mean_slsc', 'mean_WJ', 'mean_AIC', ...
    'slsc_valid_rate', 'wj_valid_rate', 'aic_valid_rate'});
end

function tbl = localBuildSummaryTable(summary)
G = numel(summary.models);
rowLabels = summary.labels(:);
slscJkCol = NaN(G, 1);
aicCol = NaN(G, 1);
noPassCol = NaN(G, 1);

for gi = 1:G
    slscJkCol(gi) = mean(summary.selection.slsc_jk(gi, :), "omitnan");
    aicCol(gi) = mean(summary.selection.aic(gi, :), "omitnan");
    noPassCol(gi) = mean(summary.selection.no_pass(gi, :), "omitnan");
end

tbl = table(rowLabels, slscJkCol, aicCol, noPassCol, ...
    'VariableNames', {'sampler', 'slsc_jk', 'aic', 'no_pass'});
end

function localWriteSelectionTableTex(tbl, texPath)
fid = fopen(texPath, "w");
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, "\\begin{table}[tb]\n");
fprintf(fid, "\\caption{sampler ごとの真モデル選択率（対象とした $N$ の平均）}\n");
fprintf(fid, "\\label{tab:true_select_rate}\n");
fprintf(fid, "\\centering\n");
fprintf(fid, "\\small\n");
fprintf(fid, "\\begin{tabular}{lrrr}\n");
fprintf(fid, "\\hline\n");
fprintf(fid, "sampler & SLSC+JK & AIC & Cand 空率 \\\\\n");
fprintf(fid, "\\hline\n");
for i = 1:height(tbl)
    fprintf(fid, "%s & %.3f & %.3f & %.3f \\\\\n", ...
        char(tbl.sampler(i)), tbl.slsc_jk(i), tbl.aic(i), tbl.no_pass(i));
end
fprintf(fid, "\\hline\n");
fprintf(fid, "\\end{tabular}\n");
fprintf(fid, "\\par\\footnotesize\n");
fprintf(fid, "Cand 空率は $\\mathrm{SLSC}\\le 0.04$ を満たす候補が存在しなかった反復の割合を表す．AIC の LN3 行は参考値として扱う．\n");
fprintf(fid, "\\end{table}\n");
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
            labels(i) = "EXP";
        case "lnormal"
            labels(i) = "LN3";
        otherwise
            labels(i) = models(i);
    end
end
end

function paperRoot = localPaperRoot()
scriptPath = mfilename("fullpath");
codeDir = fileparts(scriptPath);
paperRoot = fileparts(codeDir);
end
