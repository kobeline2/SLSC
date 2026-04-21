function out = run_criterion_subset_cases()
%RUN_CRITERION_SUBSET_CASES Run only explicitly listed (gen, N) cases.
%
% Use this when today's target is not a Cartesian product, for example:
%   - "Only 5 cases today"
%   - "GEV at N=200 and LN3 at N=950"

opts = struct();

% ----- Edit here -------------------------------------------------------
opts.stage = "base"; % jackknife, base, all

opts.projectName = "learn_smoke";
opts.projectModels = ["gumbel", "gev"];
opts.projectNlist = [20, 30];

opts.genList = ["gumbel", "gev"];
opts.Nlist = [20, 30];

opts.rep = 100;
opts.useParallel = true;
% opts.logProgress = true;      % rough progress logs
% opts.jackknifeLogEvery = 25;  % useful when opts.stage = "jackknife" or "all"
% opts.useParallel = false;     % easier-to-read logs

% opts.projectName = "paper_main";
% opts.projectModels = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
% opts.projectNlist = [50, 100, 150, 200, 250, 300, 400, 500, 700, 950];
% 
% opts.caseList = table( ...
%     ["gumbel"; "gev"; "sqrtet"; "exponential"; "lnormal"], ...
%     [50; 200; 250; 300; 950], ...
%     'VariableNames', {'gen', 'N'});
% 
% opts.rep = 100;
% opts.Tref = 100;
% opts.useParallel = true;
% opts.logProgress = true;
% opts.jackknifeLogEvery = 25;
% opts.useParallel = false;
% opts.publishToPaper = false;
% opts.force = true;
% ----------------------------------------------------------------------

out = criterion_project("run", opts);
end
