function val = SLSC_x(obs, fitRes)
%SLSC_X Least-squares criterion in X-space.
%
% This version compares observed and fitted quantiles directly in x-space
% and normalises by the fitted 0.99-0.01 quantile range.

val = simstudy.metrics.slscCore(obs, fitRes, "x");
end
