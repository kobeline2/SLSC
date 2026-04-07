function outPath = make_criterion_compare_figure(summaryPath, outPath)
%MAKE_CRITERION_COMPARE_FIGURE Rebuild Figure 2 from an existing summary MAT.
%
% Example:
%   make_criterion_compare_figure()
%   make_criterion_compare_figure("/path/to/results_summary_custom.mat")

if nargin < 1 || strlength(string(summaryPath)) == 0
    summaryPath = JSCEResultsHelper.defaultSummaryPath();
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(JSCEResultsHelper.figureDir(), "criterion_compare.pdf");
end

% ----- Edit here -------------------------------------------------------
style = struct();
style.figurePosition = [80 80 1240 860];
style.colors = [0.10 0.25 0.60; 0.82 0.22 0.18; 0.15 0.55 0.22];
style.markers = ["o", "s", "^"];
style.lineWidth = 1.8;
style.markerSize = 6;
style.tileSpacing = "compact";
style.padding = "compact";
style.yLimits = [0, 1];
% style.rows = 2;
% style.cols = 3;
% style.yLabel = "True-model selection rate";
% ----------------------------------------------------------------------

outPath = JSCEResultsHelper.makeCriterionFigureFromSummary(summaryPath, outPath, style);
fprintf("Wrote %s\n", outPath);
end
