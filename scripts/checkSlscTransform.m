% Check the S-space transform used in SLSC for one distribution.
%
% This script compares the coded transform against a reference transform
% implied by the CDF / reduced-variate definition.

% init();
paths = slscLocalPaths(true);

%% settings
model = "gev";      % "gev", "lgamma", or "sqrtet"
saveOutputs = true;
customLabel = "";

%% setup
cfg = simstudy.config.base();
theta = cfg.trueParams.(model);
u = linspace(0.01, 0.99, 300).';
x = simstudy.distributions.icdf(model, u, theta);

f = simstudy.metrics.slscTransform(model, theta);
uCode = f(x);
[uRef, refLabel] = localReferenceTransform(model, x, theta);
err = max(abs(uCode - uRef));

%% figure
fig = figure("Position", [100 100 1000 420]);
tiledlayout(1, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile;
plot(x, uCode, "LineWidth", 2, "Color", [0.1 0.25 0.55]);
hold on;
plot(x, uRef, "--", "LineWidth", 1.6, "Color", [0.8 0.2 0.2]);
title(model + " transform");
xlabel("x");
ylabel("u(x)");
legend("coded", refLabel, "Location", "best");
box on;

nexttile;
scatter(uRef, uCode, 16, "filled", "MarkerFaceAlpha", 0.35);
hold on;
lims = [min([uRef; uCode]), max([uRef; uCode])];
plot(lims, lims, "--", "Color", [0.4 0.4 0.4], "LineWidth", 1.2);
axis equal;
xlim(lims);
ylim(lims);
title("max abs err = " + string(err));
xlabel("reference u");
ylabel("coded u");
box on;

%% save
saveInfo = struct("dir", "", "figure", "", "mat", "");
if saveOutputs
    stamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
    if strlength(customLabel) == 0
        runLabel = stamp + "_" + model;
    else
        runLabel = stamp + "_" + customLabel;
    end

    outDir = fullfile(paths.scratchDir, "slsc_transform_checks", runLabel);
    if ~isfolder(outDir)
        mkdir(outDir);
    end

    figPath = fullfile(outDir, "transform_check.png");
    matPath = fullfile(outDir, "transform_check.mat");
    exportgraphics(fig, figPath, "Resolution", 200);
    save(matPath, "model", "theta", "x", "uCode", "uRef", "err", "refLabel");

    saveInfo.dir = string(outDir);
    saveInfo.figure = string(figPath);
    saveInfo.mat = string(matPath);
end

%% display
disp("Model:");
disp(model);
disp("Theta:");
disp(theta);
disp("Max abs error:");
disp(err);
if saveOutputs
    disp("Saved outputs:");
    disp(saveInfo);
end

function [uRef, label] = localReferenceTransform(model, x, theta)
model = string(model);

switch model
    case "gev"
        Fx = simstudy.distributions.cdf(model, x, theta);
        uRef = -log(-log(Fx));
        label = "-log(-log(F(x)))";
    case "sqrtet"
        Fx = simstudy.distributions.cdf(model, x, theta);
        uRef = -log(-log(Fx));
        label = "-log(-log(F(x)))";
    case "lgamma"
        Fx = simstudy.distributions.cdf(model, x, theta);
        uRef = gaminv(Fx, theta.b, 1);
        label = "gaminv(F(x), b, 1)";
    otherwise
        error("checkSlscTransform:UnknownModel", ...
            "Reference transform is not defined for model %s.", model);
end
end
