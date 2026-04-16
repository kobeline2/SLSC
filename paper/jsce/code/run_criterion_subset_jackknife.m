function out = run_criterion_subset_jackknife()
%RUN_CRITERION_SUBSET_JACKKNIFE Add jackknife only for selected cases.
%
% Typical use:
%   - base metrics are already done for many cases
%   - today you only want jackknife for a few expensive cases

opts = struct();

% ----- Edit here -------------------------------------------------------
opts.projectName = "paper_main";
opts.projectModels = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
opts.projectNlist = [50, 100, 150, 200, 250];

% Example: only case B with N = N2, N3
opts.genList = ["gev"];
opts.Nlist = [150, 200];

% Or use explicit pairs instead:
% opts.caseList = table(["gev"; "sqrtet"], [150; 250], ...
%     'VariableNames', {'gen', 'N'});

opts.rep = 100;
opts.Tref = 100;
opts.stage = "jackknife";
opts.useParallel = true;
opts.publishToPaper = false;
% ----------------------------------------------------------------------

out = criterion_project("run", opts);
end
