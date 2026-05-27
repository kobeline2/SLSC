function outPath = make_slsc_n_scaling_figure(summaryPath, outPath)
%MAKE_SLSC_N_SCALING_FIGURE Make Figure 1 for the JSCE paper.
%
% This file is intentionally self-contained.
% Edit only the block near the top, then run:
%   make_slsc_n_scaling_figure()
%   make_slsc_n_scaling_figure("/path/to/results_summary.mat")

if nargin < 1 || strlength(string(summaryPath)) == 0
    summaryPath = fullfile(localFigureDir(), "results_summary_short.mat");
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(localFigureDir(), "slsc_n_scaling_panels.pdf");
end

S = load(summaryPath, "summary");
summary = S.summary;
plotData = localPrepareSlscData(summary, summaryPath);

% ----- Edit here -------------------------------------------------------
figurePosition = [80 80 560 820];
tileRows = 3;
tileCols = 2;
tileSpacing = "compact";
tilePadding = "compact";

fitOrder = 1:numel(plotData.models);
fitColors = lines(numel(plotData.models));
lineSpec = "-o";
lineWidth = 1.5;
markerSize = 5;
errorBarWidth = 1.0;
axisFontSize = 8;
titleFontSize = 8;
labelFontSize = 9;
legendFontSize = 8;

showReferenceLine = true;
referenceLabel = "N^{-1/2}";
referenceColor = [0.2 0.2 0.2];
referenceLineWidth = 1.4;
referenceLineSpec = "--";

xLabelText = "N";
yLabelText = plotData.defaultYLabel;
legendOrientation = "horizontal";
% ----------------------------------------------------------------------

fig = figure("Visible", "off", "Position", figurePosition);
tl = tiledlayout(tileRows, tileCols, ...
    "TileSpacing", tileSpacing, ...
    "Padding", tilePadding);

handles = gobjects(numel(fitOrder) + showReferenceLine, 1);
legendLabels = strings(1, numel(fitOrder) + showReferenceLine);

for gi = 1:numel(plotData.models)
    nexttile;
    hold on;

    trueCurve = squeeze(plotData.mean(gi, gi, :)).';
    refIdx = find(isfinite(trueCurve), 1, "first");
    if showReferenceLine && ~isempty(refIdx)
        refLine = trueCurve(refIdx) * sqrt(plotData.Nlist(refIdx) ./ plotData.Nlist);
    else
        refLine = [];
    end

    legendCol = 1;
    for idx = 1:numel(fitOrder)
        fi = fitOrder(idx);
        mu = squeeze(plotData.mean(gi, fi, :)).';
        sd = squeeze(plotData.std(gi, fi, :)).';
        h = loglog(plotData.Nlist, mu, lineSpec, ...
            "LineWidth", lineWidth, ...
            "MarkerSize", markerSize, ...
            "Color", fitColors(fi, :), ...
            "MarkerFaceColor", fitColors(fi, :));
        localDrawErrorBars(plotData.Nlist, mu, sd, fitColors(fi, :), errorBarWidth);

        if gi == 1
            handles(legendCol) = h;
            legendLabels(legendCol) = plotData.labels(fi);
            legendCol = legendCol + 1;
        end
    end

    if showReferenceLine && ~isempty(refLine)
        href = loglog(plotData.Nlist, refLine, referenceLineSpec, ...
            "Color", referenceColor, ...
            "LineWidth", referenceLineWidth);
        if gi == 1
            handles(end) = href;
            legendLabels(end) = referenceLabel;
        end
    end

    title(plotData.labels(gi), "FontSize", titleFontSize, "FontWeight", "normal");
    xlabel(xLabelText, "FontSize", labelFontSize);
    ylabel(yLabelText, "FontSize", labelFontSize);
    set(gca, "XScale", "log", "YScale", "log");
    xticks(plotData.Nlist);
    xticklabels(string(plotData.Nlist));
    grid on;
    box on;
    ax = gca;
    ax.FontSize = axisFontSize;
end

validHandles = handles(isgraphics(handles));
validLabels = legendLabels(1:numel(validHandles));
lgd = legend(validHandles, validLabels, ...
    "Orientation", legendOrientation, ...
    "FontSize", legendFontSize);
lgd.Layout.Tile = "south";

exportgraphics(fig, outPath, "ContentType", "vector");
close(fig);
fprintf("Wrote %s\n", outPath);
end

function plotData = localPrepareSlscData(summary, summaryPath)
plotData = struct();
plotData.models = string(summary.models(:)).';
plotData.labels = localLabels(plotData.models);
plotData.Nlist = double(summary.Nlist(:)).';

if isfield(summary, "stats") && isfield(summary.stats, "slsc_x")
    plotData.mean = real(summary.stats.slsc_x.mean);
    plotData.std = real(summary.stats.slsc_x.std);
    plotData.defaultYLabel = "X-space SLSC";
    return;
end

if isfield(summary, "pairMeans") && isfield(summary.pairMeans, "slsc")
    plotData.mean = real(summary.pairMeans.slsc);
    plotData.std = localLoadCaseSlscStd(summary, summaryPath, plotData);
    plotData.defaultYLabel = "SLSC";
    return;
end

error("make_slsc_n_scaling_figure:UnknownSummaryFormat", ...
    "summary must contain either stats.slsc_x or pairMeans.slsc.");
end

function stdVals = localLoadCaseSlscStd(summary, summaryPath, plotData)
stdVals = NaN(size(plotData.mean));

projectRoot = "";
if isfield(summary, "projectRoot")
    projectRoot = string(summary.projectRoot);
end
if strlength(projectRoot) == 0 || ~isfolder(projectRoot)
    projectRoot = string(fileparts(summaryPath));
end

casesDir = fullfile(projectRoot, "cases");
if ~isfolder(casesDir)
    return;
end

for gi = 1:numel(plotData.models)
    gen = plotData.models(gi);
    for ni = 1:numel(plotData.Nlist)
        casePath = fullfile(casesDir, sprintf("N%d_%s.mat", plotData.Nlist(ni), char(gen)));
        if ~isfile(casePath)
            continue;
        end

        loaded = load(casePath, "caseData");
        if ~isfield(loaded, "caseData") || ...
                ~isfield(loaded.caseData, "base") || ...
                ~isfield(loaded.caseData.base, "slsc")
            continue;
        end

        stdVals(gi, :, ni) = std(real(loaded.caseData.base.slsc), 0, 1, "omitnan");
    end
end
end

function localDrawErrorBars(x, mu, sd, color, lineWidth)
for i = 1:numel(x)
    if ~(isfinite(mu(i)) && isfinite(sd(i)))
        continue;
    end
    lo = max(mu(i) - sd(i), mu(i) * 0.2);
    hi = mu(i) + sd(i);
    line([x(i), x(i)], [lo, hi], "Color", color, "LineWidth", lineWidth);
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
