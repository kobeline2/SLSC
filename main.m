edit simstudy.config.base

%% single run
cfg = simstudy.config.base();   % デフォルト: 1×1×1 グリッド
cfg.genList = ["gumbel"];
cfg.fitList = ["gumbel"];
cfg.Nlist   = [100];
cfg.rep     = 100;
experiments.runBatch(cfg);

%% grid run
disp("start")
cfg = simstudy.config.base();
% cfg.genList = ["gumbel","gev","lnormal","exponential"];
cfg.genList = ["sqrtet"];
cfg.fitList = ["gumbel","gev","lnormal"];
% cfg.fitList = ["exponential"];
cfg.Nlist   = [50, 100, 150];
cfg.rep     = 10000;
experiments.runBatch(cfg);                  % 3×3×3 グリッドを一気に実行
