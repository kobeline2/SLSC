function out = run_criterion_timing_probe()
%RUN_CRITERION_TIMING_PROBE Run a small subset and estimate full runtime.
%
% This is a rough timing tool for expensive stage="all" runs.
% It runs a small probe subset, measures wall-clock time, and extrapolates
% to the intended full run by using work units proportional to:
%   numel(genList) * rep * sum(Nlist)
%
% The estimate is intentionally rough, but it is usually good enough to
% decide whether the full run is hours, tens of hours, or longer.

% ----- Full run you want to estimate ----------------------------------
fullOpts = struct();
fullOpts.projectName = "hydro_main";
fullOpts.projectModels = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
fullOpts.projectNlist = 25:150;
fullOpts.genList = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
fullOpts.Nlist = 25:150;
fullOpts.rep = 1000;
fullOpts.Tref = 50;
fullOpts.stage = "all";
fullOpts.useParallel = true;

% ----- Small probe you actually run now -------------------------------
probeOpts = fullOpts;
probeOpts.projectName = "timing_probe_hydro";
probeOpts.Nlist = [25, 75, 150];
probeOpts.rep = 10;
probeOpts.rebuildOutputs = false;
probeOpts.publishToPaper = false;
probeOpts.force = true;
% probeOpts.logProgress = true;
% probeOpts.jackknifeLogEvery = 25;

% If you want to reduce the probe further, one simple option is:
% probeOpts.genList = ["gumbel", "sqrtet"];
% probeOpts.Nlist = [25, 150];
% probeOpts.rep = 10;
% ---------------------------------------------------------------------

fprintf("Timing probe start\n");
fprintf("  stage        : %s\n", probeOpts.stage);
fprintf("  projectModels: %s\n", strjoin(cellstr(probeOpts.projectModels), ", "));
fprintf("  probe genList: %s\n", strjoin(cellstr(probeOpts.genList), ", "));
fprintf("  probe Nlist  : %s\n", num2str(probeOpts.Nlist));
fprintf("  probe rep    : %d\n", probeOpts.rep);

tic;
runOut = criterion_project("run", probeOpts);
elapsedSeconds = toc;

probeWork = localWorkUnits(probeOpts);
fullWork = localWorkUnits(fullOpts);
scaleFactor = fullWork / probeWork;
estimatedFullSeconds = elapsedSeconds * scaleFactor;

out = struct();
out.probe = probeOpts;
out.full = fullOpts;
out.runOut = runOut;
out.elapsedSeconds = elapsedSeconds;
out.scaleFactor = scaleFactor;
out.estimatedFullSeconds = estimatedFullSeconds;
out.estimatedFullHours = estimatedFullSeconds / 3600;
out.estimatedFullDays = estimatedFullSeconds / 86400;

fprintf("\nProbe finished.\n");
fprintf("  observed wall-clock : %.1f sec (%.2f min)\n", ...
    elapsedSeconds, elapsedSeconds / 60);
fprintf("  scale factor        : %.2f\n", scaleFactor);
fprintf("  estimated full time : %.1f sec\n", estimatedFullSeconds);
fprintf("                        %.2f hours\n", out.estimatedFullHours);
fprintf("                        %.2f days\n", out.estimatedFullDays);
fprintf("\nNotes:\n");
fprintf("  - This estimate is rough.\n");
fprintf("  - It assumes runtime is roughly proportional to rep * sum(N).\n");
fprintf("  - For stage='all', jackknife usually dominates, so this is often a useful first estimate.\n");
end

function work = localWorkUnits(opts)
work = numel(opts.genList) * double(opts.rep) * sum(double(opts.Nlist));
end
