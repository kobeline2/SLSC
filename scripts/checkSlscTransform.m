% Check the S-space transform used in SLSC for one distribution.
%
% This script compares the coded transform against a reference transform
% implied by the CDF / reduced-variate definition.

% init();
paths = slscLocalPaths(true);
cfg = simstudy.config.base();

%% settings
model = "gev";      % "gev", "lgamma", "lp3", or "sqrtet"
profile = string(cfg.slscProfile);  % "japan_admin" or "eva_reduced"
variant = "";      % optional direct override for one model
saveOutputs = true;
customLabel = "";

%% setup
theta = cfg.trueParams.(model);
u = linspace(0.01, 0.99, 300).';
x = simstudy.distributions.icdf(model, u, theta);

[f, info] = simstudy.metrics.slscTransform(model, theta, ...
    Profile=profile, Variant=variant);
variant = info.variant;
uCode = f(x);
[uRef, refLabel] = localReferenceTransform(model, x, theta, info.variant);
err = max(abs(uCode - uRef));

%% figure
fig = figure("Position", [100 100 1000 420]);
tiledlayout(1, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile;
plot(x, uCode, "LineWidth", 2, "Color", [0.1 0.25 0.55]);
hold on;
plot(x, uRef, "--", "LineWidth", 1.6, "Color", [0.8 0.2 0.2]);
title(model + " transform (" + info.variant + ")");
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
    save(matPath, "model", "profile", "variant", "info", ...
        "theta", "x", "uCode", "uRef", "err", "refLabel");

    saveInfo.dir = string(outDir);
    saveInfo.figure = string(figPath);
    saveInfo.mat = string(matPath);
end

%% display
disp("Model:");
disp(model);
disp("Theta:");
disp(theta);
disp("Transform info:");
disp(info);
disp("Max abs error:");
disp(err);
if saveOutputs
    disp("Saved outputs:");
    disp(saveInfo);
end

function [uRef, label] = localReferenceTransform(model, x, theta, variant)
model = string(model);
variant = string(variant);

switch model
    case "gev"
        switch variant
            case "linear"
                uRef = (x - theta.mu) ./ theta.sigma;
                label = "(x - mu) / sigma";
            case "gev_reduced"
                Fx = simstudy.distributions.cdf(model, x, theta);
                uRef = -log(-log(Fx));
                label = "-log(-log(F(x)))";
            otherwise
                error("checkSlscTransform:UnknownVariant", ...
                    "Reference transform is not defined for GEV variant %s.", variant);
        end
    case "sqrtet"
        switch variant
            case "bx"
                uRef = theta.b .* x;
                label = "b * x";
            case "sqrtet_reduced"
                Fx = simstudy.distributions.cdf(model, x, theta);
                uRef = -log(-log(Fx));
                label = "-log(-log(F(x)))";
            otherwise
                error("checkSlscTransform:UnknownVariant", ...
                    "Reference transform is not defined for sqrt-ET variant %s.", variant);
        end
    case "lgamma"
        Fx = simstudy.distributions.cdf(model, x, theta);
        uRef = gaminv(Fx, theta.b, 1);
        label = "gaminv(F(x), b, 1)";
    case "lp3"
        Fx = simstudy.distributions.cdf(model, x, theta);
        uRef = gaminv(Fx, theta.b, 1);
        label = "gaminv(F(x), b, 1)";
    otherwise
        error("checkSlscTransform:UnknownModel", ...
            "Reference transform is not defined for model %s.", model);
end
end
