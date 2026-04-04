% Small local experiment for interactive iteration.

init();
paths = slscLocalPaths(true);

cfg = simstudy.config.base();
cfg.genList = ["gumbel", "gev"];
cfg.fitList = ["gumbel", "gev", "lnormal"];
cfg.Nlist = [30, 50, 100];
cfg.rep = 100;

runLabel = "mini_" + string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
cfg.rawDirRoot = fullfile(paths.runsDir, runLabel);
mkdir(cfg.rawDirRoot);

fprintf("Running mini grid into %s\n", cfg.rawDirRoot);
experiments.runBatch(cfg);
