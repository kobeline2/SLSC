function outPath = make_criterion_compare_figure(summaryPath, outPath)
%MAKE_CRITERION_COMPARE_FIGURE Make Figure 2 for the JSCE paper.
%
% This file is intentionally self-contained.
% Edit only the block near the top, then run:
%   make_criterion_compare_figure()
%   make_criterion_compare_figure("/path/to/results_summary.mat")

if nargin < 1 || strlength(string(summaryPath)) == 0
    summaryPath = fullfile(localFigureDir(), "results_summary_short.mat");
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(localFigureDir(), "criterion_compare.pdf");
end

S = load(summaryPath, "summary");
summary = S.summary;
summary.labels = localLabels(summary.models);

% ----- Edit here -------------------------------------------------------
figurePosition = [80 80 1240 860];
tileRows = 2;
tileCols = 3;
tileSpacing = "compact";
tilePadding = "compact";

criterionFields = ["slsc_x", "slsc", "aic"];
criterionLabels = ["X-space SLSC", "S-space SLSC", "AIC"];
criterionColors = [0.10 0.25 0.60; 0.82 0.22 0.18; 0.15 0.55 0.22];
criterionMarkers = ["o", "s", "^"];

lineSpec = "-";
lineWidth = 1.8;
markerSize = 6;
yLimits = [0, 1];
xLabelText = "N";
yLabelText = "True-model selection rate";
legendOrientation = "horizontal";
% ----------------------------------------------------------------------

fig = figure("Visible", "off", "Position", figurePosition);
tl = tiledlayout(tileRows, tileCols, ...
    "TileSpacing", tileSpacing, ...
    "Padding", tilePadding);

handles = gobjects(numel(criterionFields), 1);

for gi = 1:numel(summary.models)
    nexttile;
    hold on;

    for ci = 1:numel(criterionFields)
        y = summary.selection.(criterionFields(ci))(gi, :);
        h = plot(summary.Nlist, y, lineSpec, ...
            "LineWidth", lineWidth, ...
            "Color", criterionColors(ci, :), ...
            "Marker", criterionMarkers(ci), ...
            "MarkerSize", markerSize, ...
            "MarkerFaceColor", criterionColors(ci, :));
        if gi == 1
            handles(ci) = h;
        end
    end

    ylim(yLimits);
    xlim([min(summary.Nlist), max(summary.Nlist)]);
    xticks(summary.Nlist);
    title(summary.labels(gi));
    xlabel(xLabelText);
    ylabel(yLabelText);
    grid on;
    box on;
end

lgd = legend(handles, criterionLabels, "Orientation", legendOrientation);
lgd.Layout.Tile = "south";

exportgraphics(fig, outPath, "ContentType", "vector");
close(fig);
fprintf("Wrote %s\n", outPath);
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
