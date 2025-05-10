function r = rnd_exponential(theta, N)
% theta: struct('c', c, 'mu', \mu)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'c') || ~isfield(theta,'mu')
    error("rnd_exponential:params","theta.c and theta.mu are needed.");
end
r = theta.c + exprnd(theta.mu, N, 1);
end
