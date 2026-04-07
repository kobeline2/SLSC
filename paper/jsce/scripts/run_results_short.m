function out = run_results_short(arg)
%RUN_RESULTS_SHORT Run the short paper experiment or rebuild outputs.
%
%   out = run_results_short()
%       Run the short setup: N = [50 100 150], rep = 100.
%
%   out = run_results_short(summaryPath)
%       Rebuild summary labels and both figures from an existing summary MAT.
%
%   out = run_results_short(opts)
%       Run with a user-supplied options struct.

if nargin == 0
    opts = JSCEResultsHelper.shortOptions();
    out = JSCEResultsHelper.runExperiment(opts);
    return;
end

if isstruct(arg)
    out = JSCEResultsHelper.runExperiment(arg);
    return;
end

out = JSCEResultsHelper.rebuildFromSummary(arg);
end
