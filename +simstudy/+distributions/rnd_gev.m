function r = rnd_gev(theta, N)
% theta: struct('k', k, 'sigma', \sigma, 'mu', \mu)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'k') || ~isfield(theta,'sigma') || ~isfield(theta,'mu')
    error("rnd_gev:params","theta.k, theta.sigma, and theta.mu are needed.");
end
r = gevrnd(theta.k, theta.sigma, theta.mu, N, 1);
end