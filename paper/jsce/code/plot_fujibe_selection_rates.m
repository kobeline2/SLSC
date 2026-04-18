function outPath = plot_fujibe_selection_rates(projectName, outPath)
%PLOT_FUJIBE_SELECTION_RATES Plot fit-selection rates for Fujibe-style checks.
%
% This file is intentionally self-contained.
% Edit the block near the top, then run:
%   plot_fujibe_selection_rates()
%   plot_fujibe_selection_rates("fujibe_check")
%   plot_fujibe_selection_rates("fujibe_check", "/path/to/out.pdf")

if nargin < 1 || strlength(string(projectName)) == 0
    projectName = "fujibe_check";
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(localFigureDir(), "fujibe_selection_rates_aic.pdf");
end

projectRoot = fullfile(localProjectsRoot(), char(string(projectName)));
projectMat = load(fullfile(projectRoot, "project.mat"), "project");
project = projectMat.project;

% ----- Edit here -------------------------------------------------------
criterion = "AIC";                  % only AIC is used below
rowGens = ["gumbel", "sqrtet"];     % top and bottom panels
focusFits = ["gumbel", "sqrtet", "gev"];
figurePosition = [80 80 780 760];
tileRows = 2;
tileCols = 1;
tileSpacing = "compact";
tilePadding = "compact";

lineWidth = 1.8;
markerSize = 6;
yLimits = [0, 1];
xLabelText = "データ年数（年）";
yLabelText = "採択率";

seriesLabels = ["Gumbel", "SQRT-ET", "GEV", "Others"];
seriesColors = [0.10 0.10 0.10; 0.10 0.10 0.10; 0.10 0.10 0.10; 0.70 0.70 0.70];
seriesLineStyles = ["-", ":", "-.", "-"];
seriesMarkers = ["none", "none", "none", "none"];
legendLocation = "eastoutside";
% ----------------------------------------------------------------------

if criterion ~= "AIC"
    error("plot_fujibe_selection_rates:UnsupportedCriterion", ...
        "This script currently supports only AIC.");
end

models = string(project.models);
Nlist = double(project.Nlist);
selectionShare = localSelectionShareAIC(project, rowGens, focusFits, models, Nlist);

fig = figure("Visible", "off", "Position", figurePosition);
t = tiledlayout(tileRows, tileCols, ...
    "TileSpacing", tileSpacing, ...
    "Padding", tilePadding);

handles = gobjects(numel(seriesLabels), 1);

for gi = 1:numel(rowGens)
    nexttile;
    hold on;

    for si = 1:numel(seriesLabels)
        y = squeeze(selectionShare(gi, si, :)).';
        h = plot(Nlist, y, ...
            "Color", seriesColors(si, :), ...
            "LineStyle", seriesLineStyles(si), ...
            "LineWidth", lineWidth, ...
            "Marker", seriesMarkers(si), ...
            "MarkerSize", markerSize);
        if gi == 1
            handles(si) = h;
        end
    end

    ylim(yLimits);
    xlim([min(Nlist), max(Nlist)]);
    xticks(Nlist);
    ylabel(yLabelText);
    title(sprintf("gen = %s", localGenTitle(rowGens(gi))));
    box on;
    grid on;

    if gi == numel(rowGens)
        xlabel(xLabelText);
    end
end

lgd = legend(handles, seriesLabels, "Location", legendLocation);
lgd.Layout.Tile = "east";

title(t, "最小AIC");
exportgraphics(fig, outPath, "ContentType", "vector");
close(fig);
fprintf("Wrote %s\n", outPath);
end

function share = localSelectionShareAIC(project, rowGens, focusFits, models, Nlist)
G = numel(rowGens);
S = numel(focusFits) + 1; % + Others
K = numel(Nlist);
share = NaN(G, S, K);

for gi = 1:G
    gen = rowGens(gi);
    for ni = 1:K
        casePath = fullfile(project.casesDir, sprintf("N%d_%s.mat", Nlist(ni), char(gen)));
        if ~isfile(casePath)
            continue;
        end

        loaded = load(casePath, "caseData");
        caseData = loaded.caseData;
        idx = caseData.base.selectedAIC;
        idx = idx(isfinite(idx));
        if isempty(idx)
            continue;
        end

        for fi = 1:numel(focusFits)
            fitIdx = find(models == focusFits(fi), 1);
            share(gi, fi, ni) = mean(idx == fitIdx);
        end

        focusIdx = NaN(numel(focusFits), 1);
        for fi = 1:numel(focusFits)
            focusIdx(fi) = find(models == focusFits(fi), 1);
        end
        share(gi, end, ni) = mean(~ismember(idx, focusIdx));
    end
end
end

function titleText = localGenTitle(gen)
switch string(gen)
    case "gumbel"
        titleText = "Gumbel";
    case "sqrtet"
        titleText = "SQRT-ET";
    case "gev"
        titleText = "GEV";
    otherwise
        titleText = char(gen);
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
