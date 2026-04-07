function out = run_results_custom()
%RUN_RESULTS_CUSTOM User-editable entry point for paper experiments.
%
% Edit the block below, then run:
%   out = run_results_custom()

opts = JSCEResultsHelper.shortOptions();

% ----- Edit here -------------------------------------------------------
opts.runLabelPrefix = "paper_jsce_custom";
opts.Nlist = [50, 100, 150];
opts.rep = 100;
opts.summaryFilename = "results_summary_custom.mat";
opts.scalingFigureFilename = "slsc_n_scaling_custom.pdf";
opts.criterionFigureFilename = "criterion_compare_custom.pdf";
% opts.makeFigures = false;
% opts.models = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
% ----------------------------------------------------------------------

out = JSCEResultsHelper.runExperiment(opts);
end
