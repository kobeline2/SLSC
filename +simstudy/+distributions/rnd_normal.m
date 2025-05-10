function r = rnd_normal(theta, N)
% theta: struct('mu', \mu, 'sigma', \sigma)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'mu') || ~isfield(theta,'sigma')
    error("rnd_normal:params","theta.mu and theta.sigma are needed.");
end

r = randn(N, 1) * theta.sigma + theta.mu;
end