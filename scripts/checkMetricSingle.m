% Quick single-case check for SLSC and related metrics.
%
% Recommended usage:
%   1) edit the settings below
%   2) run this script
%
% It supports either:
%   - synthetic: data generated from cfg.trueParams
%   - workspace: an existing variable `obs` already in the workspace

% init();
paths = slscLocalPaths(true);

%% settings
dataMode = "synthetic";   % "synthetic" or "workspace"
gen = "lgamma";           % used when dataMode == "synthetic"
fit = "gumbel";
N = 100;
seed = 42;
saveOutputs = false;
customLabel = "";

%% data preparation
cfg = simstudy.config.base();

switch dataMode
    case "synthetic"
        rng(seed, "twister");
        obs = simstudy.distributions.rnd(gen, N, cfg.trueParams.(gen));
        sourceLabel = gen;
    case "workspace"
        if ~exist("obs", "var")
            error("checkMetricSingle:MissingObs", ...
                "When dataMode is 'workspace', define variable 'obs' before running this script.");
        end
        obs = obs(:);
        N = numel(obs);
        sourceLabel = "workspace";
    otherwise
        error("checkMetricSingle:InvalidMode", ...
            "dataMode must be 'synthetic' or 'workspace'.");
end

%% fit and metrics
fitRes = simstudy.estimators.MLE(fit, obs, cfg.theta0.(fit));

scores = struct();
scores.slsc = simstudy.metrics.score("SLSC", obs, fitRes);
scores.slsc_x = simstudy.metrics.score("SLSC_X", obs, fitRes);
scores.aic = simstudy.metrics.score("AIC", obs, fitRes);
scores.xentropy = simstudy.metrics.score("XENTROPY", obs, fitRes);

%% quick figure
pp = simstudy.util.plottingPosition(numel(obs), 0.4, 0.2);
xObs = sort(obs(:));
xFit = simstudy.distributions.icdf(fit, pp, fitRes.theta);
xGrid = localGrid(obs, fit, fitRes.theta);
yGrid = simstudy.distributions.pdf(fit, xGrid, fitRes.theta);

fig = figure("Position", [100 100 1000 420]);
tiledlayout(1, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile;
histogram(obs, "Normalization", "pdf", "FaceColor", [0.76 0.83 0.92]);
hold on;
plot(xGrid, yGrid, "LineWidth", 2, "Color", [0.1 0.25 0.55]);
title(sourceLabel + " data / " + fit + " fit");
xlabel("x");
ylabel("density");
box on;

nexttile;
scatter(xObs, xFit, 16, "filled", "MarkerFaceAlpha", 0.35);
hold on;
lims = [min([xObs; xFit]), max([xObs; xFit])];
plot(lims, lims, "--", "Color", [0.4 0.4 0.4], "LineWidth", 1.2);
axis equal;
xlim(lims);
ylim(lims);
title(sprintf("SLSC=%.4g, SLSC_x=%.4g", scores.slsc, scores.slsc_x));
xlabel("sorted obs");
ylabel("fitted quantiles");
box on;

%% save outputs
saveInfo = struct("dir", "", "figure", "", "mat", "");
if saveOutputs
    stamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
    if strlength(customLabel) == 0
        runLabel = stamp + "_" + sourceLabel + "2" + fit + "_N" + string(N);
    else
        runLabel = stamp + "_" + customLabel;
    end

    outDir = fullfile(paths.scratchDir, "metric_checks", runLabel);
    if ~isfolder(outDir)
        mkdir(outDir);
    end

    figPath = fullfile(outDir, "metric_check.png");
    matPath = fullfile(outDir, "metric_check.mat");
    exportgraphics(fig, figPath, "Resolution", 200);
    save(matPath, "obs", "fitRes", "scores", "dataMode", "gen", "fit", "N", "seed");

    saveInfo.dir = string(outDir);
    saveInfo.figure = string(figPath);
    saveInfo.mat = string(matPath);
end

%% display
disp("Scores:");
disp(scores);
disp("Fit result:");
disp(fitRes);
if saveOutputs
    disp("Saved outputs:");
    disp(saveInfo);
end

function xGrid = localGrid(obs, fit, theta)
fit = string(fit);
lo = min(obs);
hi = max(obs);

try
    qLo = simstudy.distributions.icdf(fit, 0.005, theta);
    qHi = simstudy.distributions.icdf(fit, 0.995, theta);
    lo = min([lo; qLo]);
    hi = max([hi; qHi]);
catch
    % fall back to data range
end

if ~(isfinite(lo) && isfinite(hi)) || lo == hi
    lo = min(obs) - 1;
    hi = max(obs) + 1;
end

xGrid = linspace(lo, hi, 300);
end
