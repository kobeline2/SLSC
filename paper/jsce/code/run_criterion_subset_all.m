function out = run_criterion_subset_all()
%RUN_CRITERION_SUBSET_ALL Run selected cases with base + jackknife together.
%
% Edit only the block below. This is the easiest entry point when someone asks:
% "What happens for these distributions and these N values?"

opts = struct();
opts.stage = "all";

% ----- Edit here -------------------------------------------------------
opts.projectName = "paper_main";
opts.projectModels = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
opts.projectNlist = [50, 100, 150, 200, 250];

% Cartesian product:
opts.genList = ["gumbel", "gev", "lp3"];
opts.Nlist = [50, 100, 150];

% Or use explicit case pairs instead:
% opts.caseList = table(["gumbel"; "gev"; "sqrtet"], [50; 200; 250], ...
%     'VariableNames', {'gen', 'N'});

opts.rep = 100;
opts.Tref = 100;
opts.useParallel = true;
opts.publishToPaper = false;
% opts.force = true;
% ----------------------------------------------------------------------

out = criterion_project("run", opts);
end
