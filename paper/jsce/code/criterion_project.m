function out = criterion_project(action, opts)
%CRITERION_PROJECT Run, rebuild, and inspect incremental criterion projects.
%
%   out = criterion_project("run", opts)
%       Run selected (gen, N) cases for one project.
%
%   out = criterion_project("rebuild", opts)
%       Rebuild summary / CSV / TeX / figure from existing case files.
%
%   out = criterion_project("status", opts)
%       Show which cases are done.
%
% The intended workflow is:
%   1. Create one project with the full model list and full N list.
%   2. Run only a subset of cases today.
%   3. Add jackknife later for a smaller subset.
%   4. Rebuild outputs from the cases accumulated so far.

if nargin < 1 || strlength(string(action)) == 0
    action = "run";
end
if nargin < 2
    opts = struct();
end

action = lower(string(action));

switch action
    case "run"
        out = localRunProject(opts);
    case "rebuild"
        out = localRebuildProject(opts);
    case "status"
        out = localStatusProject(opts);
    otherwise
        error("criterion_project:UnknownAction", ...
            "Unknown action %s. Use run, rebuild, or status.", action);
end
end

function out = localRunProject(opts)
init();

defaults = localProjectDefaults();
opts = localFillDefaults(opts, defaults);
opts.stage = localCanonicalStage(opts.stage);

[project, opts] = localLoadOrCreateProject(opts);
tasks = localResolveTasks(project, opts);

if isempty(tasks)
    fprintf("No cases selected.\n");
    out = struct("projectRoot", string(project.rootDir), "caseFiles", strings(0, 1));
    return;
end

fprintf("Project : %s\n", project.name);
fprintf("Stage   : %s\n", opts.stage);
fprintf("Cases   : %d\n", numel(tasks));

caseFiles = strings(numel(tasks), 1);

if opts.useParallel && numel(tasks) > 1
    parfor ti = 1:numel(tasks)
        caseFiles(ti) = localRunOneCase(tasks(ti), project, opts);
    end
else
    for ti = 1:numel(tasks)
        caseFiles(ti) = localRunOneCase(tasks(ti), project, opts);
    end
end

out = struct();
out.projectRoot = string(project.rootDir);
out.caseFiles = caseFiles(:);

if opts.rebuildOutputs
    rebuildOut = localRebuildProject(opts);
    out.summaryPath = rebuildOut.summaryPath;
    out.selectionCsvPath = rebuildOut.selectionCsvPath;
    out.pairMeansCsvPath = rebuildOut.pairMeansCsvPath;
    out.tableTexPath = rebuildOut.tableTexPath;
    out.figurePath = rebuildOut.figurePath;
end
end

function out = localRebuildProject(opts)
defaults = localProjectDefaults();
opts = localFillDefaults(opts, defaults);
project = localLoadExistingProject(opts.projectName);

summary = localBuildSummaryFromCases(project);

summaryPath = fullfile(project.rootDir, "criterion_summary.mat");
selectionCsvPath = fullfile(project.rootDir, "criterion_selection_rates.csv");
pairMeansCsvPath = fullfile(project.rootDir, "criterion_pair_means.csv");
tableTexPath = fullfile(project.rootDir, "criterion_selection_table.tex");
figurePath = fullfile(project.rootDir, "criterion_compare.pdf");

save(summaryPath, "summary", "project");

selectionTable = localBuildSelectionRateTable(summary);
pairMeansTable = localBuildPairMeansTable(summary);
summaryTable = localBuildSummaryTable(summary);

writetable(selectionTable, selectionCsvPath);
writetable(pairMeansTable, pairMeansCsvPath);
localWriteSelectionTableTex(summaryTable, tableTexPath);

plot_criterion_compare(summaryPath, figurePath);

if opts.publishToPaper
    localPublishToPaper(project, tableTexPath, figurePath);
end

out = struct();
out.projectRoot = string(project.rootDir);
out.summaryPath = string(summaryPath);
out.selectionCsvPath = string(selectionCsvPath);
out.pairMeansCsvPath = string(pairMeansCsvPath);
out.tableTexPath = string(tableTexPath);
out.figurePath = string(figurePath);
out.summary = summary;
end

function out = localStatusProject(opts)
defaults = localProjectDefaults();
opts = localFillDefaults(opts, defaults);
project = localLoadExistingProject(opts.projectName);

tbl = localBuildStatusTable(project);
disp(tbl);

fprintf("\nBase done      : %d / %d\n", sum(tbl.base_done), height(tbl));
fprintf("Jackknife done : %d / %d\n", sum(tbl.jackknife_done), height(tbl));

out = tbl;
end

function caseFile = localRunOneCase(task, project, opts)
casePath = fullfile(project.casesDir, sprintf("N%d_%s.mat", task.N, char(task.gen)));
caseData = localLoadCaseOrDefault(casePath, task, project);

skip = false;
switch opts.stage
    case "base"
        skip = caseData.baseDone && ~opts.force;
    case "jackknife"
        skip = caseData.jackknifeDone && ~opts.force;
    case "all"
        skip = caseData.baseDone && caseData.jackknifeDone && ~opts.force;
end

if skip
    fprintf("Skip N=%d, gen=%s (already done for stage %s)\n", ...
        task.N, task.gen, opts.stage);
    caseFile = string(casePath);
    return;
end

needBase = any(opts.stage == ["base", "all"]) || ...
    (~caseData.baseDone && opts.stage == "jackknife");
needJackknife = any(opts.stage == ["jackknife", "all"]);

F = numel(project.models);
R = project.rep;

if needBase
    base = localEmptyBase(R, F);
else
    base = caseData.base;
end

if needJackknife
    jk = localEmptyJackknife(R, F);
else
    jk = caseData.jackknife;
end

cfg = simstudy.config.base();
cfg.seed = project.seed;
cfg.slscProfile = project.slscProfile;
cfg.slscTransforms = project.slscTransforms;

if opts.logProgress
    fprintf("[case] gen=%s N=%d stage=%s start\n", task.gen, task.N, opts.stage);
end

for r = 1:R
    substream = localSubstreamIndex(project, task.genIdx, task.NIdx, r);
    caseData.substream(r) = substream;
    obs = localGenerateObs(project, task, substream);

    if opts.logProgress
        fprintf("[case] gen=%s N=%d rep=%d/%d substream=%d\n", ...
            task.gen, task.N, r, R, substream);
    end

    slscRow = NaN(1, F);
    slscValidRow = false(1, F);
    wjRow = NaN(1, F);
    jkValidRow = false(1, F);
    aicRow = NaN(1, F);
    aicValidRow = false(1, F);

    for fi = 1:F
        fit = project.models(fi);
        [fitRes, fitStats] = localEvaluateFullFit(obs, fit, cfg, project);

        slscRow(fi) = fitStats.slsc;
        slscValidRow(fi) = fitStats.slscValid;
        aicRow(fi) = fitStats.aic;
        aicValidRow(fi) = fitStats.aicValid;

        if needBase
            base.slsc(r, fi) = fitStats.slsc;
            base.aic(r, fi) = fitStats.aic;
            base.p0(r, fi) = fitStats.p0;
            base.exitflag(r, fi) = fitStats.exitflag;
            base.slscValid(r, fi) = fitStats.slscValid;
            base.aicValid(r, fi) = fitStats.aicValid;
            base.p0Valid(r, fi) = fitStats.p0Valid;
        end

        if needJackknife && fitStats.p0Valid
            logPrefix = sprintf("[jk] gen=%s N=%d rep=%d/%d fit=%s", ...
                task.gen, task.N, r, R, fit);
            if opts.logProgress
                fprintf("%s start\n", logPrefix);
            end

            [wj, ok] = localJackknifeWidth(obs, fit, fitRes.theta, cfg, project, opts, logPrefix);
            wjRow(fi) = wj;
            jkValidRow(fi) = ok;

            if opts.logProgress
                fprintf("%s done ok=%d WJ=%.6g\n", logPrefix, ok, wj);
            end
        end
    end

    if needBase
        base.selectedAIC(r) = localSelectMin(aicRow, aicValidRow);
    end

    if needJackknife
        jk.wj(r, :) = wjRow;
        jk.jkValid(r, :) = jkValidRow;

        passMask = slscValidRow & jkValidRow & ...
            isfinite(slscRow) & (slscRow <= project.slscThreshold);
        jk.noPass(r) = ~any(passMask);

        if any(passMask)
            candMask = passMask;
        else
            candMask = jkValidRow & isfinite(wjRow);
        end
        jk.selectedSLSCJK(r) = localSelectMin(wjRow, candMask);
    end
end

if needBase
    caseData.base = base;
    caseData.baseDone = true;
end

if needJackknife
    caseData.jackknife = jk;
    caseData.jackknifeDone = true;
end

caseData.updatedAt = string(datetime("now"));
save(casePath, "caseData");

fprintf("Done N=%d, gen=%s, stage=%s -> %s\n", ...
    task.N, task.gen, opts.stage, casePath);
caseFile = string(casePath);
end

function [project, opts] = localLoadOrCreateProject(opts)
projectRoot = fullfile(localProjectsRoot(), char(opts.projectName));
casesDir = fullfile(projectRoot, "cases");
configPath = fullfile(projectRoot, "project.mat");

if isfile(configPath)
    loaded = load(configPath, "project");
    project = loaded.project;
    localValidateProject(project, opts);
    return;
end

if ~isfolder(projectRoot), mkdir(projectRoot); end
if ~isfolder(casesDir), mkdir(casesDir); end

project = struct();
project.name = string(opts.projectName);
project.rootDir = string(projectRoot);
project.casesDir = string(casesDir);
project.models = string(opts.projectModels);
project.labels = localLabels(project.models);
project.Nlist = double(opts.projectNlist(:)).';
project.rep = double(opts.rep);
project.seed = double(opts.seed);
project.Tref = double(opts.Tref);
project.slscThreshold = double(opts.slscThreshold);
project.slscProfile = string(opts.slscProfile);
project.slscTransforms = opts.slscTransforms;
project.createdAt = string(datetime("now"));

save(configPath, "project");
end

function project = localLoadExistingProject(projectName)
configPath = fullfile(localProjectsRoot(), char(string(projectName)), "project.mat");
if ~isfile(configPath)
    error("criterion_project:MissingProject", ...
        "Project %s does not exist.", projectName);
end
loaded = load(configPath, "project");
project = loaded.project;
end

function localValidateProject(project, opts)
if ~isequal(string(project.models), string(opts.projectModels))
    error("criterion_project:ModelMismatch", ...
        "Project models do not match the requested projectModels.");
end

if ~isequal(double(project.Nlist), double(opts.projectNlist(:)).')
    error("criterion_project:NlistMismatch", ...
        "Project N list does not match the requested projectNlist.");
end

checkFields = { ...
    "rep", "seed", "Tref", "slscThreshold"};
for i = 1:numel(checkFields)
    key = checkFields{i};
    if double(project.(key)) ~= double(opts.(key))
        error("criterion_project:ConfigMismatch", ...
            "Project setting %s does not match the requested value.", key);
    end
end

if string(project.slscProfile) ~= string(opts.slscProfile)
    error("criterion_project:ProfileMismatch", ...
        "Project slscProfile does not match the requested value.");
end
end

function tasks = localResolveTasks(project, opts)
if ~isempty(opts.caseList)
    tasks = localTasksFromCaseList(project, opts.caseList);
    return;
end

genList = string(opts.genList);
if isempty(genList)
    genList = string(project.models);
end

Nlist = double(opts.Nlist(:)).';
if isempty(Nlist)
    Nlist = double(project.Nlist);
end

tasks = repmat(struct( ...
    "gen", "", ...
    "N", 0, ...
    "genIdx", 0, ...
    "NIdx", 0), numel(genList) * numel(Nlist), 1);

ti = 1;
for gi = 1:numel(genList)
    gen = string(genList(gi));
    genIdx = find(string(project.models) == gen, 1);
    if isempty(genIdx)
        error("criterion_project:UnknownGen", ...
            "Unknown gen %s for project %s.", gen, project.name);
    end
    for ni = 1:numel(Nlist)
        N = double(Nlist(ni));
        NIdx = find(double(project.Nlist) == N, 1);
        if isempty(NIdx)
            error("criterion_project:UnknownN", ...
                "Unknown N=%g for project %s.", N, project.name);
        end

        tasks(ti).gen = gen;
        tasks(ti).N = N;
        tasks(ti).genIdx = genIdx;
        tasks(ti).NIdx = NIdx;
        ti = ti + 1;
    end
end
end

function tasks = localTasksFromCaseList(project, caseList)
if istable(caseList)
    genCol = string(caseList.gen);
    nCol = double(caseList.N);
elseif isstruct(caseList)
    genCol = strings(numel(caseList), 1);
    nCol = NaN(numel(caseList), 1);
    for i = 1:numel(caseList)
        genCol(i) = string(caseList(i).gen);
        nCol(i) = double(caseList(i).N);
    end
else
    error("criterion_project:InvalidCaseList", ...
        "caseList must be a table or struct array with fields gen and N.");
end

tasks = repmat(struct( ...
    "gen", "", ...
    "N", 0, ...
    "genIdx", 0, ...
    "NIdx", 0), numel(genCol), 1);

for i = 1:numel(genCol)
    gen = genCol(i);
    N = nCol(i);
    genIdx = find(string(project.models) == gen, 1);
    NIdx = find(double(project.Nlist) == N, 1);
    if isempty(genIdx) || isempty(NIdx)
        error("criterion_project:InvalidCase", ...
            "Case (%s, %g) is not in the project grid.", gen, N);
    end
    tasks(i).gen = gen;
    tasks(i).N = N;
    tasks(i).genIdx = genIdx;
    tasks(i).NIdx = NIdx;
end
end

function caseData = localLoadCaseOrDefault(casePath, task, project)
if isfile(casePath)
    loaded = load(casePath, "caseData");
    caseData = loaded.caseData;
    return;
end

R = project.rep;
F = numel(project.models);

caseData = struct();
caseData.projectName = string(project.name);
caseData.gen = string(task.gen);
caseData.N = double(task.N);
caseData.genIdx = double(task.genIdx);
caseData.NIdx = double(task.NIdx);
caseData.models = string(project.models);
caseData.substream = NaN(R, 1);
caseData.baseDone = false;
caseData.jackknifeDone = false;
caseData.base = localEmptyBase(R, F);
caseData.jackknife = localEmptyJackknife(R, F);
caseData.updatedAt = "";
end

function base = localEmptyBase(R, F)
base = struct();
base.slsc = NaN(R, F);
base.aic = NaN(R, F);
base.p0 = NaN(R, F);
base.exitflag = NaN(R, F);
base.slscValid = false(R, F);
base.aicValid = false(R, F);
base.p0Valid = false(R, F);
base.selectedAIC = NaN(R, 1);
end

function jk = localEmptyJackknife(R, F)
jk = struct();
jk.wj = NaN(R, F);
jk.jkValid = false(R, F);
jk.selectedSLSCJK = NaN(R, 1);
jk.noPass = false(R, 1);
end

function substream = localSubstreamIndex(project, genIdx, NIdx, repIdx)
substream = ((genIdx - 1) * numel(project.Nlist) + (NIdx - 1)) * project.rep + repIdx;
end

function obs = localGenerateObs(project, task, substream)
rs = RandStream("Threefry", "Seed", project.seed);
rs.Substream = substream;
RandStream.setGlobalStream(rs);

genKey = char(task.gen);
cfg = simstudy.config.base();
obs = simstudy.distributions.rnd(genKey, task.N, cfg.trueParams.(genKey));
obs = obs(:);
end

function [fitRes, stats] = localEvaluateFullFit(obs, fit, cfg, project)
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
    fitRes = localAttachSlscConfig(fitRes, project, fit);
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
        stats.p0 = simstudy.distributions.icdf(fitKey, localPRef(project.Tref), fitRes.theta);
    catch
        stats.p0 = NaN;
    end
    stats.p0Valid = localValidExitflag(fitRes.exitflag) && isfinite(stats.p0);
catch
    fitRes = struct("theta", cfg.theta0.(fitKey));
end
end

function fitRes = localAttachSlscConfig(fitRes, project, fit)
fitRes.slscProfile = string(project.slscProfile);

if isstruct(project.slscTransforms)
    key = char(string(fit));
    if isfield(project.slscTransforms, key)
        fitRes.slscTransformVariant = string(project.slscTransforms.(key));
    end
end
end

function [wj, ok] = localJackknifeWidth(obs, fit, thetaInit, cfg, project, opts, logPrefix)
fitKey = char(string(fit));
N = numel(obs);
pj = NaN(N, 1);
ok = true;
logEvery = max(1, double(opts.jackknifeLogEvery));

for j = 1:N
    obsMinus = obs;
    obsMinus(j) = [];
    try
        fitRes = simstudy.estimators.MLE(fitKey, obsMinus, thetaInit);
        if ~localValidExitflag(fitRes.exitflag)
            ok = false;
            break;
        end
        pj(j) = simstudy.distributions.icdf(fitKey, localPRef(project.Tref), fitRes.theta);
        if ~isfinite(pj(j))
            ok = false;
            break;
        end
    catch
        ok = false;
        break;
    end

    if opts.logProgress && (j == 1 || j == N || mod(j, logEvery) == 0)
        fprintf("%s leave-one-out %d/%d\n", logPrefix, j, N);
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

function summary = localBuildSummaryFromCases(project)
models = string(project.models);
labels = localLabels(models);
Nlist = double(project.Nlist);
G = numel(models);
F = numel(models);
K = numel(Nlist);

summary = struct();
summary.projectName = string(project.name);
summary.models = models;
summary.labels = labels;
summary.Nlist = Nlist;
summary.rep = project.rep;
summary.seed = project.seed;
summary.Tref = project.Tref;
summary.slscThreshold = project.slscThreshold;
summary.projectRoot = string(project.rootDir);
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
summary.caseStatus = struct();
summary.caseStatus.baseDone = false(G, K);
summary.caseStatus.jackknifeDone = false(G, K);
summary.caseFiles = strings(G, K);

for gi = 1:G
    for ni = 1:K
        casePath = fullfile(project.casesDir, sprintf("N%d_%s.mat", Nlist(ni), char(models(gi))));
        summary.caseFiles(gi, ni) = string(casePath);
        if ~isfile(casePath)
            continue;
        end

        loaded = load(casePath, "caseData");
        caseData = loaded.caseData;

        summary.caseStatus.baseDone(gi, ni) = caseData.baseDone;
        summary.caseStatus.jackknifeDone(gi, ni) = caseData.jackknifeDone;

        if caseData.baseDone
            summary.selection.aic(gi, ni) = mean(caseData.base.selectedAIC == gi);
            summary.pairMeans.slsc(gi, :, ni) = mean(caseData.base.slsc, 1, "omitnan");
            summary.pairMeans.aic(gi, :, ni) = mean(caseData.base.aic, 1, "omitnan");
            summary.pairMeans.slscValidRate(gi, :, ni) = mean(caseData.base.slscValid, 1);
            summary.pairMeans.aicValidRate(gi, :, ni) = mean(caseData.base.aicValid, 1);
        end

        if caseData.jackknifeDone
            summary.selection.slsc_jk(gi, ni) = mean(caseData.jackknife.selectedSLSCJK == gi);
            summary.selection.no_pass(gi, ni) = mean(caseData.jackknife.noPass);
            summary.pairMeans.wj(gi, :, ni) = mean(caseData.jackknife.wj, 1, "omitnan");
            summary.pairMeans.wjValidRate(gi, :, ni) = mean(caseData.jackknife.jkValid, 1);
        end
    end
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

function tbl = localBuildStatusTable(project)
models = string(project.models);
Nlist = double(project.Nlist);
rows = numel(models) * numel(Nlist);

genCol = strings(rows, 1);
Ncol = NaN(rows, 1);
baseDoneCol = false(rows, 1);
jackknifeDoneCol = false(rows, 1);
fileCol = strings(rows, 1);

ri = 1;
for gi = 1:numel(models)
    for ni = 1:numel(Nlist)
        casePath = fullfile(project.casesDir, sprintf("N%d_%s.mat", Nlist(ni), char(models(gi))));
        genCol(ri) = models(gi);
        Ncol(ri) = Nlist(ni);
        fileCol(ri) = string(casePath);
        if isfile(casePath)
            loaded = load(casePath, "caseData");
            baseDoneCol(ri) = loaded.caseData.baseDone;
            jackknifeDoneCol(ri) = loaded.caseData.jackknifeDone;
        end
        ri = ri + 1;
    end
end

tbl = table(genCol, Ncol, baseDoneCol, jackknifeDoneCol, fileCol, ...
    'VariableNames', {'gen', 'N', 'base_done', 'jackknife_done', 'file'});
end

function localPublishToPaper(project, tableTexPath, figurePath)
paperRoot = localPaperRoot();
paperOutDir = fullfile(paperRoot, "out");
paperFigDir = fullfile(paperRoot, "fig", "results");
if ~isfolder(paperOutDir), mkdir(paperOutDir); end
if ~isfolder(paperFigDir), mkdir(paperFigDir); end

copyfile(tableTexPath, fullfile(paperOutDir, "criterion_selection_table.tex"));
copyfile(figurePath, fullfile(paperFigDir, "criterion_compare.pdf"));

fprintf("Published project %s outputs to paper/jsce.\n", project.name);
end

function defaults = localProjectDefaults()
defaults = struct();
defaults.projectName = "paper_main";
defaults.projectModels = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
defaults.projectNlist = [50, 100, 150];
defaults.genList = strings(0, 1);
defaults.Nlist = [];
defaults.caseList = [];
defaults.rep = 100;
defaults.seed = 42;
defaults.slscThreshold = 0.04;
defaults.Tref = 100;
defaults.slscProfile = "japan_admin";
defaults.slscTransforms = struct();
defaults.stage = "all";
defaults.useParallel = true;
defaults.rebuildOutputs = true;
defaults.publishToPaper = false;
defaults.force = false;
defaults.logProgress = false;
defaults.jackknifeLogEvery = 50;
end

function opts = localFillDefaults(opts, defaults)
keys = fieldnames(defaults);
for i = 1:numel(keys)
    key = keys{i};
    if ~isfield(opts, key)
        opts.(key) = defaults.(key);
    end
end

opts.projectName = string(opts.projectName);
opts.projectModels = string(opts.projectModels);
opts.projectNlist = double(opts.projectNlist(:)).';
opts.genList = string(opts.genList);
opts.Nlist = double(opts.Nlist(:)).';
opts.rep = double(opts.rep);
opts.seed = double(opts.seed);
opts.slscThreshold = double(opts.slscThreshold);
opts.Tref = double(opts.Tref);
opts.useParallel = logical(opts.useParallel);
opts.rebuildOutputs = logical(opts.rebuildOutputs);
opts.publishToPaper = logical(opts.publishToPaper);
opts.force = logical(opts.force);
opts.logProgress = logical(opts.logProgress);
opts.jackknifeLogEvery = double(opts.jackknifeLogEvery);
end

function stage = localCanonicalStage(stage)
stage = lower(string(stage));
if ~any(stage == ["base", "jackknife", "all"])
    error("criterion_project:UnknownStage", ...
        "Unknown stage %s. Use base, jackknife, or all.", stage);
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
            labels(i) = "EXP";
        case "lnormal"
            labels(i) = "LN3";
        otherwise
            labels(i) = models(i);
    end
end
end

function rootDir = localProjectsRoot()
rootDir = fullfile(localPaperRoot(), "out", "criterion_projects");
if ~isfolder(rootDir)
    mkdir(rootDir);
end
end

function paperRoot = localPaperRoot()
thisFile = mfilename("fullpath");
codeDir = fileparts(thisFile);
paperRoot = fileparts(codeDir);
end
