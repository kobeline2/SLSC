%% grid run
cfg = simstudy.config.base();
cfg.genList = ["lgamma", "sqrtet"];
% cfg.fitList = cfg.genList;
cfg.fitList = ["lnormal", "exponential"];
cfg.Nlist   = [50 100 150];
cfg.rep     = 10000;
experiments.runBatch2(cfg);                  % 3×3×3 グリッドを一気に実行
