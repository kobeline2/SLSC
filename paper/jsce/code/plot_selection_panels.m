function outPath = plot_selection_panels(projectName, criterion, outPath)
%PLOT_SELECTION_PANELS Plot per-fit selection shares for one criterion.
%
% Example
%   addpath('/Users/takahiro/Documents/git/SLSC/paper/jsce/code');
%   plot_selection_panels("jsce2026_rep10000", "slsc_jk");
%   plot_selection_panels("jsce2026_rep10000", "aic");

if nargin < 1 || strlength(string(projectName)) == 0
    projectName = "jsce2026_rep10000";
end
if nargin < 2 || strlength(string(criterion)) == 0
    criterion = "slsc_jk";
end
criterion = lower(string(criterion));
if nargin < 3 || strlength(string(outPath)) == 0
    switch criterion
        case "slsc_jk"
            outPath = fullfile(localFigureDir(), "slsc_jackknife_selection_panels.pdf");
        case "aic"
            outPath = fullfile(localFigureDir(), "aic_selection_panels.pdf");
        otherwise
            error("plot_selection_panels:UnknownCriterion", ...
                "Unknown criterion %s", criterion);
    end
end

projectRoot = fullfile(localProjectsRoot(), char(string(projectName)));
projectMat = load(fullfile(projectRoot, "project.mat"), "project");
project = projectMat.project;

models = string(project.models(:)).';
labels = localLabels(models);
Nlist = double(project.Nlist(:)).';
share = localSelectionShare(projectRoot, project, criterion, models, Nlist);
if all(isnan(share), "all")
    error("plot_selection_panels:NoSelectionData", ...
        "No finite selection data were found for criterion %s in project %s.", ...
        criterion, projectName);
end

% ----- Edit here -------------------------------------------------------
figurePosition = [80 80 760 980];
tileRows = 3;
tileCols = 2;
tileSpacing = "compact";
tilePadding = "compact";

lineWidth = 1.2;
markerSize = 0.1;
yLimits = [0, 1];
yTicks = [0, 0.5, 1.0];
axisFontSize = 8;
titleFontSize = 8;
legendFontSize = 8;
legendNumColumns = 3;

xTickIdx = unique([1, round((numel(Nlist)+1)/2), numel(Nlist)]);
xTicks = Nlist(xTickIdx);

seriesColors = [ ...
    0.12 0.12 0.12; ...   % Gumbel
    0.10 0.33 0.75; ...   % GEV
    0.75 0.34 0.14; ...   % P3/LP3
    0.10 0.55 0.32; ...   % SqrtEt
    0.58 0.18 0.57; ...   % EXP
    0.78 0.16 0.22];      % LN3
seriesLineStyles = ["-", "--", ":", "-.", "-", "--"];
criterionCaption = localCriterionCaption(criterion);
% ----------------------------------------------------------------------

fig = figure("Visible", "off", "Color", "w", "Position", figurePosition);
t = tiledlayout(tileRows, tileCols, ...
    "TileSpacing", tileSpacing, ...
    "Padding", tilePadding);

handles = gobjects(numel(models), 1);

for gi = 1:numel(models)
    ax = nexttile;
    hold(ax, "on");

    for fi = 1:numel(models)
        y = squeeze(share(gi, fi, :)).';
        h = plot(ax, Nlist, y, ...
            "Color", seriesColors(fi, :), ...
            "LineStyle", seriesLineStyles(fi), ...
            "LineWidth", lineWidth, ...
            "Marker", "none", ...
            "MarkerSize", markerSize);
        if gi == 1
            handles(fi) = h;
        end
    end

    title(ax, labels(gi), "FontSize", titleFontSize, "FontWeight", "normal");
    xlim(ax, [min(Nlist), max(Nlist)]);
    ylim(ax, yLimits);
    xticks(ax, xTicks);
    yticks(ax, yTicks);
    box(ax, "on");
    grid(ax, "off");
    ax.LineWidth = 0.6;
    ax.FontSize = axisFontSize;
    ax.TickDir = "out";
    ax.TickLength = [0.015 0.015];

    row = ceil(gi / tileCols);
    col = gi - (row - 1) * tileCols;

    if row < tileRows
        ax.XTickLabel = [];
    end
    if col > 1
        ax.YTickLabel = [];
    end
end

xlabel(t, "N", "FontSize", axisFontSize + 1);
ylabel(t, "採択率", "FontSize", axisFontSize + 1);
lgd = legend(handles, labels, ...
    "Orientation", "horizontal", ...
    "NumColumns", legendNumColumns, ...
    "FontSize", legendFontSize, ...
    "Box", "off");
lgd.Layout.Tile = "south";
title(t, criterionCaption, "FontSize", axisFontSize + 1, "FontWeight", "normal");

exportgraphics(fig, outPath, "ContentType", "vector");
close(fig);
fprintf("Wrote %s\n", outPath);
end

function share = localSelectionShare(projectRoot, project, criterion, models, Nlist)
G = numel(models);
F = numel(models);
K = numel(Nlist);
share = NaN(G, F, K);
casesDir = fullfile(projectRoot, "cases");

for gi = 1:G
    gen = models(gi);
    for ni = 1:K
        casePath = fullfile(casesDir, sprintf("N%d_%s.mat", Nlist(ni), char(gen)));
        if ~isfile(casePath)
            continue;
        end

        loaded = load(casePath, "caseData");
        caseData = loaded.caseData;
        switch criterion
            case "aic"
                idx = caseData.base.selectedAIC;
            case "slsc_jk"
                idx = caseData.jackknife.selectedSLSCJK;
            otherwise
                error("plot_selection_panels:UnknownCriterion", ...
                    "Unknown criterion %s", criterion);
        end

        idx = idx(isfinite(idx));
        if isempty(idx)
            continue;
        end

        for fi = 1:F
            share(gi, fi, ni) = mean(idx == fi);
        end
    end
end
end

function labels = localLabels(models)
labels = strings(size(models));
for i = 1:numel(models)
    switch string(models(i))
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
            labels(i) = string(models(i));
    end
end
end

function txt = localCriterionCaption(criterion)
switch criterion
    case "slsc_jk"
        txt = "SLSC+ジャックナイフ法";
    case "aic"
        txt = "AIC";
    otherwise
        txt = char(criterion);
end
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

function rootDir = localProjectsRoot()
scriptPath = mfilename("fullpath");
codeDir = fileparts(scriptPath);
paperRoot = fileparts(codeDir);
rootDir = fullfile(paperRoot, "out", "criterion_projects");
end
