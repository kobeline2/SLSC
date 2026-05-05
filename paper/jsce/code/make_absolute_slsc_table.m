function out = make_absolute_slsc_table(projectRef, opts)
%MAKE_ABSOLUTE_SLSC_TABLE Build an absolute-mean SLSC table from a project.
%
% Example
%   addpath('/Users/takahiro/Documents/git/SLSC/paper/jsce/code');
%   make_absolute_slsc_table("jsce2026_rep10000");

arguments
    projectRef = "jsce2026_rep10000"
    opts.Nlist double = []
    opts.OutputFilename string = "absolute_slsc_table.tex"
    opts.Caption string = "各組合せでの平均 SLSC 値（対象とした $N$ の平均）"
    opts.Label string = "tab:absolute_slsc"
    opts.PublishToPaper (1,1) logical = true
    opts.LegacyLgammaLabel string = "P3"
    opts.IncludeLn3X (1,1) logical = false
    opts.BoldBelowSelfFit (1,1) logical = true
    opts.DropLeadingZero (1,1) logical = true
    opts.UseParallel (1,1) logical = false
    opts.Ln3XCacheFilename string = "ln3x_mean_cache.mat"
end

projectRoot = localResolveProjectRoot(projectRef);
summaryPath = fullfile(projectRoot, "criterion_summary.mat");
if ~isfile(summaryPath)
    error("make_absolute_slsc_table:MissingSummary", ...
        "criterion_summary.mat not found: %s", summaryPath);
end

loaded = load(summaryPath, "summary", "project");
summary = loaded.summary;
if isfield(loaded, "project")
    project = loaded.project;
else
    projectLoaded = load(fullfile(projectRoot, "project.mat"), "project");
    project = projectLoaded.project;
end

models = string(summary.models(:)).';
allN = double(summary.Nlist(:)).';
labels = localLabels(models, opts.LegacyLgammaLabel);

if isempty(opts.Nlist)
    nMask = true(size(allN));
else
    nMask = ismember(allN, opts.Nlist);
    if ~any(nMask)
        error("make_absolute_slsc_table:NoMatchingN", ...
            "Requested N values are not present in the project output.");
    end
end

values = mean(summary.pairMeans.slsc(:, :, nMask), 3, "omitnan");
colLabels = labels;
colModels = models;
lnIdx = find(models == "lnormal", 1);
if ~isempty(lnIdx)
    colLabels(lnIdx) = "LN3(S)";
end

if opts.IncludeLn3X && ~isempty(lnIdx)
    ln3xMeanByN = localLoadOrComputeLn3XMeans(projectRoot, project, summary, opts);
    ln3xCol = mean(ln3xMeanByN(:, nMask), 2, "omitnan");

    values = [values(:, 1:lnIdx-1), ln3xCol, values(:, lnIdx:end)];
    colLabels = [colLabels(1:lnIdx-1), "LN3(X)", colLabels(lnIdx:end)];
    colModels = [colModels(1:lnIdx-1), "lnormal_x", colModels(lnIdx:end)];
end

tbl = struct();
tbl.rowLabels = labels(:);
tbl.rowModels = models(:);
tbl.colLabels = colLabels(:).';
tbl.colModels = colModels(:).';
tbl.values = values;
tbl.usedN = allN(nMask);
tbl.highlight = localHighlightMask(tbl, opts.BoldBelowSelfFit);
tbl.display = localFormatValues(tbl.values, tbl.highlight, opts.DropLeadingZero);

texPath = fullfile(projectRoot, opts.OutputFilename);
localWriteTex(tbl, texPath, opts.Caption, opts.Label, opts.IncludeLn3X);

if opts.PublishToPaper
    paperOutDir = localPaperOutDir();
    if ~isfolder(paperOutDir)
        mkdir(paperOutDir);
    end
    copyfile(texPath, fullfile(paperOutDir, char(opts.OutputFilename)));
end

disp("Absolute SLSC table preview:");
localPrintPreview(tbl);

out = struct();
out.projectRoot = string(projectRoot);
out.texPath = string(texPath);
out.table = tbl;
end

function projectRoot = localResolveProjectRoot(projectRef)
projectRef = string(projectRef);
if isfolder(projectRef)
    projectRoot = char(projectRef);
    return;
end

codeDir = fileparts(mfilename("fullpath"));
jsceDir = fileparts(codeDir);
projectRoot = fullfile(jsceDir, "out", "criterion_projects", char(projectRef));
end

function outDir = localPaperOutDir()
codeDir = fileparts(mfilename("fullpath"));
jsceDir = fileparts(codeDir);
outDir = fullfile(jsceDir, "out");
end

function labels = localLabels(models, legacyLgammaLabel)
models = string(models);
labels = strings(size(models));
for i = 1:numel(models)
    switch models(i)
        case "gumbel"
            labels(i) = "Gumbel";
        case "gev"
            labels(i) = "GEV";
        case "lgamma"
            labels(i) = legacyLgammaLabel;
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

function ln3xMeanByN = localLoadOrComputeLn3XMeans(projectRoot, project, summary, opts)
cachePath = fullfile(projectRoot, opts.Ln3XCacheFilename);
models = string(summary.models(:)).';
Nlist = double(summary.Nlist(:)).';
G = numel(models);
K = numel(Nlist);

if isfile(cachePath)
    loaded = load(cachePath, "cache");
    if isfield(loaded, "cache") && ...
            isequal(string(loaded.cache.models(:)).', models) && ...
            isequal(double(loaded.cache.Nlist(:)).', Nlist) && ...
            double(loaded.cache.rep) == double(project.rep)
        ln3xMeanByN = loaded.cache.mean;
        return;
    end
end

tasks = repmat(struct("gen", "", "N", 0, "genIdx", 0, "NIdx", 0), G * K, 1);
ti = 1;
for gi = 1:G
    for ni = 1:K
        tasks(ti).gen = models(gi);
        tasks(ti).N = Nlist(ni);
        tasks(ti).genIdx = gi;
        tasks(ti).NIdx = ni;
        ti = ti + 1;
    end
end

caseMeans = NaN(numel(tasks), 1);
if opts.UseParallel && numel(tasks) > 1
    parfor ti = 1:numel(tasks)
        caseMeans(ti) = localComputeOneLn3XCase(projectRoot, project, tasks(ti));
    end
else
    for ti = 1:numel(tasks)
        fprintf("[LN3(X)] case %d/%d: gen=%s, N=%d\n", ...
            ti, numel(tasks), tasks(ti).gen, tasks(ti).N);
        caseMeans(ti) = localComputeOneLn3XCase(projectRoot, project, tasks(ti));
    end
end

ln3xMeanByN = NaN(G, K);
for ti = 1:numel(tasks)
    ln3xMeanByN(tasks(ti).genIdx, tasks(ti).NIdx) = caseMeans(ti);
end

cache = struct();
cache.models = models;
cache.Nlist = Nlist;
cache.rep = project.rep;
cache.mean = ln3xMeanByN;
cache.updatedAt = string(datetime("now"));
save(cachePath, "cache");
end

function meanVal = localComputeOneLn3XCase(projectRoot, project, task)
casePath = fullfile(projectRoot, "cases", sprintf("N%d_%s.mat", task.N, char(task.gen)));
loaded = load(casePath, "caseData");
caseData = loaded.caseData;

cfg = simstudy.config.base();
R = numel(caseData.substream);
vals = NaN(R, 1);

for r = 1:R
    substream = caseData.substream(r);
    if ~isfinite(substream)
        substream = ((task.genIdx - 1) * numel(project.Nlist) + (task.NIdx - 1)) * project.rep + r;
    end
    obs = localGenerateObs(project, task.gen, task.N, substream, cfg);
    try
        fitRes = simstudy.estimators.MLE('lnormal', obs, cfg.theta0.lnormal);
        if isfinite(fitRes.loglik) && ~isempty(fitRes.exitflag) && isfinite(fitRes.exitflag) && fitRes.exitflag > 0
            vals(r) = simstudy.metrics.score('SLSC_X', obs, fitRes);
        end
    catch
        vals(r) = NaN;
    end
end

meanVal = mean(vals, "omitnan");
end

function obs = localGenerateObs(project, gen, N, substream, cfg)
rs = RandStream("Threefry", "Seed", project.seed);
rs.Substream = substream;
RandStream.setGlobalStream(rs);
obs = simstudy.distributions.rnd(char(gen), N, cfg.trueParams.(char(gen)));
obs = obs(:);
end

function highlight = localHighlightMask(tbl, doHighlight)
[nRow, nCol] = size(tbl.values);
highlight = false(nRow, nCol);
if ~doHighlight
    return;
end

for i = 1:nRow
    rowModel = string(tbl.rowModels(i));
    if rowModel == "lnormal"
        baseIdx = find(ismember(string(tbl.colModels), ["lnormal_x", "lnormal"]));
    else
        baseIdx = find(string(tbl.colModels) == rowModel, 1);
    end
    if isempty(baseIdx)
        continue;
    end
    baseline = min(tbl.values(i, baseIdx), [], "omitnan");
    if ~isfinite(baseline)
        continue;
    end
    for j = 1:nCol
        highlight(i, j) = isfinite(tbl.values(i, j)) && (tbl.values(i, j) < baseline - 1e-12);
    end
end
end

function displayVals = localFormatValues(values, highlight, dropLeadingZero)
[nRow, nCol] = size(values);
displayVals = strings(nRow, nCol);
for i = 1:nRow
    for j = 1:nCol
        displayVals(i, j) = localFormatOne(values(i, j), highlight(i, j), dropLeadingZero);
    end
end
end

function out = localFormatOne(value, isBold, dropLeadingZero)
if ~isfinite(value)
    out = "--";
    return;
end
out = string(sprintf("%.3f", real(value)));
if dropLeadingZero
    out = regexprep(out, '^0(?=\.)', '');
    out = regexprep(out, '^-0(?=\.)', '-');
end
if isBold
    out = "\\textbf{" + out + "}";
end
end

function localWriteTex(tbl, texPath, captionText, labelText, includeLn3X)
fid = fopen(texPath, "w");
cleanup = onCleanup(@() fclose(fid));

nCols = numel(tbl.colLabels);
rowEnd = char([32 92 92]);

fprintf(fid, "\\begin{table}[tb]\n");
fprintf(fid, "\\caption{%s}\n", char(captionText));
fprintf(fid, "\\label{%s}\n", char(labelText));
fprintf(fid, "\\centering\n");
fprintf(fid, "\\scriptsize\n");
fprintf(fid, "\\setlength{\\tabcolsep}{3pt}\n");
fprintf(fid, "\\begin{tabular}{l%s}\n", repmat('r', 1, nCols));
fprintf(fid, "\\hline\n");
fprintf(fid, "sampler");
for j = 1:nCols
    fprintf(fid, " & %s", char(tbl.colLabels(j)));
end
fprintf(fid, "%s\n", rowEnd);
fprintf(fid, "\\hline\n");

for i = 1:numel(tbl.rowLabels)
    fprintf(fid, "%s", char(tbl.rowLabels(i)));
    for j = 1:nCols
        fprintf(fid, " & %s", char(tbl.display(i, j)));
    end
    fprintf(fid, "%s\n", rowEnd);
end

fprintf(fid, "\\hline\n");
fprintf(fid, "\\end{tabular}\n");
fprintf(fid, "\\par\\footnotesize\n");
fprintf(fid, "値は対象とした標本サイズにわたる平均 SLSC 値である．");
if includeLn3X
    fprintf(fid, "LN3(X) は X 空間, LN3(S) は S 空間で評価した値を示す．");
else
    fprintf(fid, "LN3 列は S 空間で評価した値を示す．");
end
fprintf(fid, "太字は同一 sampler 行において self-fit 値より小さいものを示す．\n");
fprintf(fid, "\\end{table}\n");
end

function localPrintPreview(tbl)
header = "sampler";
for j = 1:numel(tbl.colLabels)
    header = header + sprintf("\t%s", tbl.colLabels(j));
end
disp(char(header));

for i = 1:numel(tbl.rowLabels)
    lineText = tbl.rowLabels(i);
    for j = 1:numel(tbl.colLabels)
        lineText = lineText + sprintf("\t%s", tbl.display(i, j));
    end
    disp(char(lineText));
end
end
