function cfg = run(cfgInput)
%RUN Execute a single (gen, fit, N) experiment using the current cfg format.
%
%   cfg = experiments.run()
%   cfg = experiments.run(cfg)
%   cfg = experiments.run(@simstudy.config.base)
%
% This is a thin convenience wrapper around experiments.runBatch.
% It expects scalar selections for:
%   cfg.genList
%   cfg.fitList
%   cfg.Nlist

if nargin == 0
    cfg = simstudy.config.base();
elseif isa(cfgInput, "function_handle")
    cfg = feval(cfgInput);
else
    cfg = cfgInput;
end

cfg = localNormalizeCfg(cfg);
experiments.runBatch(cfg);
end

function cfg = localNormalizeCfg(cfg)
if ~isfield(cfg, "genList") || ~isfield(cfg, "fitList") || ~isfield(cfg, "Nlist")
    error("experiments:run:InvalidCfg", ...
        "cfg must contain genList, fitList, and Nlist.");
end

cfg.genList = string(cfg.genList);
cfg.fitList = string(cfg.fitList);
cfg.Nlist = double(cfg.Nlist);

if numel(cfg.genList) ~= 1 || numel(cfg.fitList) ~= 1 || numel(cfg.Nlist) ~= 1
    error("experiments:run:NonScalarGrid", ...
        "experiments.run expects exactly one gen, one fit, and one N.");
end

cfg.genList = reshape(cfg.genList, 1, 1);
cfg.fitList = reshape(cfg.fitList, 1, 1);
cfg.Nlist = reshape(cfg.Nlist, 1, 1);
end
