function out = refitKyotoTrueParams(opts)
%REFITKYOTOTRUEPARAMS Refit distribution parameters to Kyoto annual maxima.
%
% This script documents the provenance of cfg.trueParams in
% simstudy.config.base. The default data file is:
%   local/data/kyoto/kyoto_max.xlsx
%
% Example:
%   init();
%   out = refitKyotoTrueParams();

arguments
    opts.DataPath string = ""
    opts.Models string = ["gumbel", "gev", "lgamma", "lp3", "sqrtet", "exponential", "lnormal"]
    opts.SaveReport (1,1) logical = true
    opts.ReportName string = "kyoto_true_params_latest"
end

paths = slscLocalPaths(true);
if strlength(opts.DataPath) == 0
    opts.DataPath = fullfile(paths.dataDir, "kyoto", "kyoto_max.xlsx");
end

cfg = simstudy.config.base();
data = readmatrix(opts.DataPath);
obs = data(:, 2);
obs = obs(isfinite(obs));

models = string(opts.Models(:)).';
fits = struct();
rows = table('Size', [numel(models), 5], ...
    'VariableTypes', {'string', 'double', 'double', 'logical', 'string'}, ...
    'VariableNames', {'model', 'loglik', 'exitflag', 'ok', 'theta'});

fprintf("Kyoto annual maxima: %s\n", opts.DataPath);
fprintf("N = %d\n\n", numel(obs));

for i = 1:numel(models)
    model = models(i);
    fitRes = simstudy.estimators.MLE(model, obs, cfg.theta0.(model));

    fits.(model) = fitRes;
    rows.model(i) = model;
    rows.loglik(i) = fitRes.loglik;
    rows.exitflag(i) = fitRes.exitflag;
    rows.ok(i) = isfinite(fitRes.loglik) && fitRes.exitflag > 0;
    rows.theta(i) = localThetaText(fitRes.theta);

    fprintf("%-12s loglik=%12.6f exitflag=%g theta=%s\n", ...
        model, fitRes.loglik, fitRes.exitflag, rows.theta(i));
end

out = struct();
out.dataPath = opts.DataPath;
out.N = numel(obs);
out.models = models;
out.fits = fits;
out.summary = rows;

fprintf("\nSuggested cfg.trueParams entries:\n");
for i = 1:numel(models)
    model = models(i);
    fprintf("    '%s', %s, ...\n", model, localStructLiteral(fits.(model).theta));
end

if opts.SaveReport
    reportDir = fullfile(paths.dataDir, "kyoto");
    if ~isfolder(reportDir)
        mkdir(reportDir);
    end
    matPath = fullfile(reportDir, opts.ReportName + ".mat");
    csvPath = fullfile(reportDir, opts.ReportName + ".csv");
    save(matPath, "out");
    writetable(rows, csvPath);
    out.files = struct("mat", string(matPath), "csv", string(csvPath));
    fprintf("\nSaved report:\n  %s\n  %s\n", matPath, csvPath);
end
end

function txt = localThetaText(theta)
names = string(fieldnames(theta));
parts = strings(size(names));
for i = 1:numel(names)
    parts(i) = names(i) + "=" + sprintf("%.10g", theta.(names(i)));
end
txt = strjoin(parts, ", ");
end

function txt = localStructLiteral(theta)
names = string(fieldnames(theta));
parts = strings(size(names));
for i = 1:numel(names)
    parts(i) = "'" + names(i) + "'," + sprintf("%.10g", theta.(names(i)));
end
txt = "struct(" + strjoin(parts, ",") + ")";
end
