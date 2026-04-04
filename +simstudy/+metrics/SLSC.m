function val = SLSC(obs, fitRes)
%SLSC Standard Least-Squares Criterion in S-space.
%
% This version applies a model-specific transform s = sv(x), then compares
% observed and fitted plotting positions in the transformed space.

val = simstudy.metrics.slscCore(obs, fitRes, "s");
end
