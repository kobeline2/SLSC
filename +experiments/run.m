function run(cfgFunc)
% cfgFunc : handle to config function (default = @simstudy.config.base)

if nargin==0, cfgFunc = @simstudy.config.single; end
cfg = feval(cfgFunc);

% -------- result folder --------
tag = sprintf("N%d_%s2%s", cfg.sampleSize, cfg.genModel, cfg.fitModels);
outDir = fullfile("results", tag);
if ~exist(outDir,"dir"), mkdir(outDir), end

% -------- master seed ----------
masterSeed = cfg.seed;

% -------- parallel loop --------
parfor r = 1:cfg.repetitions
    % sub-stream for reproducibility
    rs = RandStream('Threefry','Seed', masterSeed);
    rs.Substream = r; 

    % --- 1 trial ---------------------------------------------
    obs   = simstudy.distributions.rnd(cfg.genModel, cfg.sampleSize, cfg.trueParams.(cfg.genModel));
    fitRes = simstudy.estimators.MLE(cfg.fitModels, obs, cfg.theta0.(cfg.fitModels));
    score  = simstudy.metrics.SLSC(obs, fitRes);

    % --- save -------------------------------------------------
    fname = fullfile(outDir, sprintf("rep%04d.mat", r));
    simstudy.util.parsave(fname, score, fitRes); 
end
end

