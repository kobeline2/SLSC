function report = runDistributionCheck(model, opts)
%RUNDISTRIBUTIONCHECK Quick consistency checks and figures for one model.
%
%   report = simstudy.validation.runDistributionCheck(model)
%   report = simstudy.validation.runDistributionCheck(model, opts)

arguments
    model string
    opts.N (1,1) double {mustBeInteger, mustBePositive} = 500
    opts.GridSize (1,1) double {mustBeInteger, mustBePositive} = 200
    opts.RoundTripTol (1,1) double {mustBePositive} = 1e-6
    opts.SaveDir string = ""
    opts.MakeFigure (1,1) logical = true
    opts.Seed (1,1) double = 42
end

cfg = simstudy.config.base();
theta = cfg.trueParams.(model);
theta0 = cfg.theta0.(model);

rng(opts.Seed, "twister");
report = struct();
report.model = model;
report.theta = theta;
report.timestamp = string(datetime("now"));
report.checks = struct();
report.files = struct("figure", "", "mat", "");

obs = simstudy.distributions.rnd(model, opts.N, theta);
obs = obs(:);
obs = sort(obs);
u = linspace(1e-4, 1-1e-4, opts.GridSize).';
xq = simstudy.distributions.icdf(model, u, theta);

report.checks.roundTrip = localTry(@() localRoundTrip(model, theta, u, opts.RoundTripTol));
report.checks.cdfMonotone = localTry(@() localCdfMonotone(model, theta, xq));
report.checks.pdfNonnegative = localTry(@() localPdfNonnegative(model, theta, xq));
report.checks.loglikeFinite = localTry(@() localLoglikeFinite(model, theta, obs));
report.checks.mleSelfFit = localTry(@() localMLE(model, theta0, obs));

if opts.MakeFigure
    fig = localMakeFigure(model, theta, obs, xq, u, report);
    if strlength(opts.SaveDir) > 0
        if ~isfolder(opts.SaveDir)
            mkdir(opts.SaveDir);
        end
        figPath = fullfile(opts.SaveDir, model + "_diagnostic.png");
        exportgraphics(fig, figPath, "Resolution", 200);
        report.files.figure = string(figPath);
        close(fig);
    end
end

if strlength(opts.SaveDir) > 0
    matPath = fullfile(opts.SaveDir, model + "_report.mat");
    save(matPath, "report");
    report.files.mat = string(matPath);
end
end

function out = localRoundTrip(model, theta, u, tol)
x = simstudy.distributions.icdf(model, u, theta);
u2 = simstudy.distributions.cdf(model, x, theta);
err = max(abs(u - u2));
out = struct("ok", err <= tol, "value", err, "detail", "max|u-cdf(icdf(u))|");
end

function out = localCdfMonotone(model, theta, x)
Fx = simstudy.distributions.cdf(model, x, theta);
d = diff(Fx);
ok = all(isfinite(Fx)) && all(d >= -1e-10) && Fx(1) >= -1e-10 && Fx(end) <= 1 + 1e-10;
out = struct("ok", ok, "value", min([d; Fx(1); 1 - Fx(end)]), "detail", "cdf monotonicity/support");
end

function out = localPdfNonnegative(model, theta, x)
fx = simstudy.distributions.pdf(model, x, theta);
out = struct("ok", all(isfinite(fx)) && all(fx >= -1e-12), ...
    "value", min(fx), "detail", "min pdf on quantile grid");
end

function out = localLoglikeFinite(model, theta, obs)
ll = simstudy.distributions.loglike(model, obs, theta);
out = struct("ok", isfinite(ll), "value", ll, "detail", "loglike at true theta");
end

function out = localMLE(model, theta0, obs)
fitRes = simstudy.estimators.MLE(model, obs, theta0);
llFit = simstudy.distributions.loglike(model, obs, fitRes.theta);
llTrue = simstudy.distributions.loglike(model, obs, theta0);
ok = isfinite(llFit) && localValidExitflag(fitRes.exitflag);
out = struct("ok", ok, "value", llFit, ...
    "detail", "MLE loglike on self-sample", ...
    "fitTheta", fitRes.theta, ...
    "fitLoglik", llFit, ...
    "initLoglik", llTrue, ...
    "exitflag", fitRes.exitflag);
end

function ok = localValidExitflag(exitflag)
ok = isfinite(exitflag) && exitflag > 0;
end

function fig = localMakeFigure(model, theta, obs, xq, u, report)
fig = figure("Visible", "off", "Position", [100 100 1100 800]);
tiledlayout(2, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile;
histogram(obs, "Normalization", "pdf", "FaceColor", [0.75 0.82 0.92]);
hold on;
fx = simstudy.distributions.pdf(model, xq, theta);
plot(xq, fx, "LineWidth", 2, "Color", [0.1 0.25 0.55]);
title(model + " histogram vs pdf");
xlabel("x");
ylabel("density");
box on;

nexttile;
[fEmp, xEmp] = ecdf(obs);
plot(xEmp, fEmp, "LineWidth", 1.5, "Color", [0.3 0.3 0.3]);
hold on;
Fx = simstudy.distributions.cdf(model, xq, theta);
plot(xq, Fx, "LineWidth", 2, "Color", [0.8 0.2 0.2]);
title("empirical cdf vs theoretical cdf");
xlabel("x");
ylabel("F(x)");
legend("empirical", "theoretical", "Location", "best");
box on;

nexttile;
u2 = simstudy.distributions.cdf(model, xq, theta);
plot(u, u2, ".", "MarkerSize", 10, "Color", [0.1 0.45 0.15]);
hold on;
plot([0 1], [0 1], "--", "Color", [0.4 0.4 0.4]);
title("cdf(icdf(u)) round-trip");
xlabel("u");
ylabel("cdf(icdf(u))");
axis square;
box on;

nexttile;
axis off;
lines = localSummaryLines(theta, report.checks);
text(0, 1, strjoin(lines, newline), "VerticalAlignment", "top", ...
    "FontName", "Courier", "FontSize", 10);
title("summary");
end

function lines = localSummaryLines(theta, checks)
lines = ["theta:"; string(evalc("disp(theta)"))];
names = string(fieldnames(checks));
for i = 1:numel(names)
    item = checks.(names(i));
    if isfield(item, "error")
        status = "ERROR";
        value = item.error;
    elseif item.ok
        status = "OK";
        value = string(item.value);
    else
        status = "FAIL";
        value = string(item.value);
    end
    lines(end+1,1) = sprintf("%-14s %-5s %s", names(i), status, value); %#ok<AGROW>
end
end

function out = localTry(fun)
try
    out = fun();
catch ME
    out = struct("ok", false, "value", NaN, "detail", "", "error", string(ME.message));
end
end
