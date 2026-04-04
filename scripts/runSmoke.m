% Small end-to-end run for checking that the simulation pipeline works.

init();
paths = slscLocalPaths(true);

cfg = simstudy.config.base();
cfg.genList = ["gumbel"];
cfg.fitList = ["gumbel"];
cfg.Nlist = 50;
cfg.rep = 20;

runLabel = "smoke_" + string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
cfg.rawDirRoot = fullfile(paths.runsDir, runLabel);
mkdir(cfg.rawDirRoot);

fprintf("Running smoke test into %s\n", cfg.rawDirRoot);
experiments.runBatch(cfg);
