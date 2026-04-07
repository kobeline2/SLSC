function outPath = make_slsc_n_scaling_figure(summaryPath, outPath)
%MAKE_SLSC_N_SCALING_FIGURE Rebuild Figure 1 from an existing summary MAT.
%
% Example:
%   make_slsc_n_scaling_figure()
%   make_slsc_n_scaling_figure("/path/to/results_summary_custom.mat")

if nargin < 1 || strlength(string(summaryPath)) == 0
    summaryPath = JSCEResultsHelper.defaultSummaryPath();
end
if nargin < 2 || strlength(string(outPath)) == 0
    outPath = fullfile(JSCEResultsHelper.figureDir(), "slsc_n_scaling_panels.pdf");
end

% ----- Edit here -------------------------------------------------------
style = struct();
style.figurePosition = [80 80 1280 860];
style.colors = lines(6);
style.lineWidth = 1.5;
style.markerSize = 5;
style.errorBarWidth = 1.0;
style.referenceColor = [0.2 0.2 0.2];
style.referenceLineWidth = 1.4;
style.tileSpacing = "compact";
style.padding = "compact";
% style.rows = 2;
% style.cols = 3;
% style.yLabel = "X-space SLSC";
% ----------------------------------------------------------------------

outPath = JSCEResultsHelper.makeScalingFigureFromSummary(summaryPath, outPath, style);
fprintf("Wrote %s\n", outPath);
end
