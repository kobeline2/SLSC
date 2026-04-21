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
summary.labels = localLabels(summary.models);

% ----- Edit here -------------------------------------------------------
figurePosition = [80 80 1280 860];
tileRows = 2;
tileCols = 3;
tileSpacing = "compact";
tilePadding = "compact";

fitOrder = 1:numel(summary.models);
fitColors = lines(numel(summary.models));
lineSpec = "-o";
lineWidth = 1.5;
markerSize = 5;
errorBarWidth = 1.0;

showReferenceLine = true;
referenceLabel = "N^{-1/2}";
referenceColor = [0.2 0.2 0.2];
referenceLineWidth = 1.4;
referenceLineSpec = "--";

xLabelText = "N";
yLabelText = "X-space SLSC";
legendOrientation = "horizontal";
% ----------------------------------------------------------------------

fig = figure("Visible", "off", "Position", figurePosition);
tl = tiledlayout(tileRows, tileCols, ...
    "TileSpacing", tileSpacing, ...
    "Padding", tilePadding);

handles = gobjects(numel(fitOrder) + showReferenceLine, 1);
legendLabels = strings(1, numel(fitOrder) + showReferenceLine);

for gi = 1:numel(summary.models)
    nexttile;
    hold on;

    trueCurve = squeeze(summary.stats.slsc_x.mean(gi, gi, :)).';
    refIdx = find(isfinite(trueCurve), 1, "first");
    if showReferenceLine && ~isempty(refIdx)
        refLine = trueCurve(refIdx) * sqrt(summary.Nlist(refIdx) ./ summary.Nlist);
    else
        refLine = [];
    end

    legendCol = 1;
    for idx = 1:numel(fitOrder)
        fi = fitOrder(idx);
        mu = squeeze(summary.stats.slsc_x.mean(gi, fi, :)).';
        sd = squeeze(summary.stats.slsc_x.std(gi, fi, :)).';
        h = loglog(summary.Nlist, mu, lineSpec, ...
            "LineWidth", lineWidth, ...
            "MarkerSize", markerSize, ...
            "Color", fitColors(fi, :), ...
            "MarkerFaceColor", fitColors(fi, :));
        localDrawErrorBars(summary.Nlist, mu, sd, fitColors(fi, :), errorBarWidth);

        if gi == 1
            handles(legendCol) = h;
            legendLabels(legendCol) = summary.labels(fi);
            legendCol = legendCol + 1;
        end
    end

    if showReferenceLine && ~isempty(refLine)
        href = loglog(summary.Nlist, refLine, referenceLineSpec, ...
            "Color", referenceColor, ...
            "LineWidth", referenceLineWidth);
        if gi == 1
            handles(end) = href;
            legendLabels(end) = referenceLabel;
        end
    end

    title(summary.labels(gi));
    xlabel(xLabelText);
    ylabel(yLabelText);
    set(gca, "XScale", "log", "YScale", "log");
    xticks(summary.Nlist);
    xticklabels(string(summary.Nlist));
    grid on;
    box on;
end

validHandles = handles(isgraphics(handles));
validLabels = legendLabels(1:numel(validHandles));
lgd = legend(validHandles, validLabels, "Orientation", legendOrientation);
lgd.Layout.Tile = "south";

exportgraphics(fig, outPath, "ContentType", "vector");
close(fig);
fprintf("Wrote %s\n", outPath);
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
