function val = SLSC(obs, fitRes)
%SLSC Standard Least-Squares Criterion in S-space.
%
% This version applies a model-specific transform s = sv(x), then compares
% observed and fitted plotting positions in the transformed space.
% The transform family can be controlled via fitRes.slscProfile and
% fitRes.slscTransformVariant.

val = simstudy.metrics.slscCore(obs, fitRes, "s");
end
