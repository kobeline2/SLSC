% Run consistency checks for one distribution and save outputs locally.
% distList = ["gumbel", "normal", "exponential", "gev", "sqrtet", "lnormal", "lgamma"]
paths = slscLocalPaths(true);

for model = distList
% model = "normal";
stamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outDir = fullfile(paths.validationDir, "single_" + stamp, model);

report = simstudy.validation.runDistributionCheck(model, ...
    "SaveDir", outDir, ...
    "N", 500, ...
    "GridSize", 200, ...
    "RoundTripTol", 1e-6);

disp(report.checks);
disp(report.files);
end