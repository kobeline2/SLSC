edit simstudy.config.base

%% single run
cfg = simstudy.config.base();   % デフォルト: 1×1×1 グリッド
cfg.genList = ["gumbel"];
cfg.fitList = ["gumbel"];
cfg.Nlist   = [50];
cfg.rep     = 100;
experiments.runBatch(cfg);

%% grid run
cfg = simstudy.config.base();
cfg.genList = ["lgamma","sqrtet","gumbel","gev","lnormal","exponential"];
cfg.fitList = cfg.genList;
cfg.Nlist   = [50 100 150];
cfg.rep     = 10000;
experiments.runBatch(cfg);                  % 3×3×3 グリッドを一気に実行
