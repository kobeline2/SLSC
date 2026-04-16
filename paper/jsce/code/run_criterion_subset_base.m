function out = run_criterion_subset_base()
%RUN_CRITERION_SUBSET_BASE Run only base metrics for selected cases.
%
% Use this when you want to accumulate AIC / SLSC first, and add jackknife later.

opts = struct();

% ----- Edit here -------------------------------------------------------
opts.projectName = "paper_main";
opts.projectModels = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
opts.projectNlist = [50, 100, 150, 200, 250];

opts.genList = ["gumbel", "gev", "lnormal"];
opts.Nlist = [100, 150, 200];

opts.rep = 100;
opts.Tref = 100;
opts.stage = "base";
opts.useParallel = true;
opts.publishToPaper = false;
% ----------------------------------------------------------------------

out = criterion_project("run", opts);
end
