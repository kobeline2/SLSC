function out = run_criterion_subset_base()
%RUN_CRITERION_SUBSET_BASE Run only base metrics for selected cases.
%
% Use this when you want to accumulate AIC / SLSC first, and add jackknife later.

opts = struct();
opts.stage = "base";

% ----- Edit here -------------------------------------------------------
opts.projectName = "fujibe_check";
opts.projectModels = ["gumbel", "sqrtet", "gev"];
opts.projectNlist = [30, 100, 300, 1000];

opts.genList = ["gumbel", "sqrtet", "gev"];
opts.Nlist = [30, 100, 300, 1000];

opts.rep = 1000;   % まずは適当に。必要に応じて増やす
opts.Tref = 100;
opts.useParallel = true;
opts.publishToPaper = false;
% opts.projectName = "paper_main";
% opts.projectModels = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
% opts.projectNlist = [50, 100, 150, 200, 250];
% 
% opts.genList = ["gumbel", "gev", "lnormal"];
% opts.Nlist = [100, 150, 200];
% 
% opts.rep = 100;
% opts.Tref = 100;
% opts.useParallel = true;
% opts.publishToPaper = false;
% ----------------------------------------------------------------------

out = criterion_project("run", opts);
end
