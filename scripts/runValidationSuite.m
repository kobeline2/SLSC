% Run consistency checks for all configured distributions.

init();
paths = slscLocalPaths(true);

cfg = simstudy.config.base();
modelList = string(cfg.genList);
stamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outDir = fullfile(paths.validationDir, "suite_" + stamp);

reports = simstudy.validation.runSuite(modelList, ...
    "RootDir", outDir, ...
    "N", 500, ...
    "GridSize", 200, ...
    "RoundTripTol", 1e-6);

disp(string({reports.model})');
disp("Validation outputs:");
disp(outDir);
