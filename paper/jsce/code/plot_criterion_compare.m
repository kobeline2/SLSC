function outPath = plot_criterion_compare(summaryPath, outPath)
%PLOT_CRITERION_COMPARE Make the JSCE criterion comparison figure.
%
% This file is intentionally self-contained.
% Edit only the block near the top, then run:
%   plot_criterion_compare()
%   plot_criterion_compare("/path/to/criterion_compare_summary.mat")

if nargin < 1 || strlength(string(summaryPath)) == 0
    summaryPath = fullfile(localOutDir(), "criterion_compare_summary.mat");
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(localFigureDir(), "criterion_compare.pdf");
end

S = load(summaryPath, "summary");
summary = S.summary;

% ----- Edit here -------------------------------------------------------
figurePosition = [80 80 1240 860];
tileRows = 2;
tileCols = 3;
tileSpacing = "compact";
tilePadding = "compact";

criterionFields = ["slsc_jk", "aic"];
criterionLabels = ["SLSC+JK", "AIC"];
criterionColors = [0.10 0.25 0.60; 0.82 0.22 0.18];
criterionMarkers = ["o", "s"];

lineSpec = "-";
lineWidth = 1.8;
markerSize = 6;
yLimits = [0, 1];
xLabelText = "N";
yLabelText = "True-model selection rate";
legendOrientation = "horizontal";
% ----------------------------------------------------------------------

fig = figure("Visible", "off", "Position", figurePosition);
tiledlayout(tileRows, tileCols, ...
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
    if numel(summary.Nlist) == 1
        xlim([summary.Nlist(1) - 0.5, summary.Nlist(1) + 0.5]);
    else
        xlim([min(summary.Nlist), max(summary.Nlist)]);
    end
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

function figDir = localFigureDir()
scriptPath = mfilename("fullpath");
codeDir = fileparts(scriptPath);
paperRoot = fileparts(codeDir);
figDir = fullfile(paperRoot, "fig", "results");
if ~isfolder(figDir)
    mkdir(figDir);
end
end

function outDir = localOutDir()
scriptPath = mfilename("fullpath");
codeDir = fileparts(scriptPath);
paperRoot = fileparts(codeDir);
outDir = fullfile(paperRoot, "out");
if ~isfolder(outDir)
    mkdir(outDir);
end
end
