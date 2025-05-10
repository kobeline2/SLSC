function r = rnd_lnormal(theta, N)
% theta: struct('c', c, 'mu', \mu, 'sigma', \sigma)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'c') || ~isfield(theta,'mu') || ~isfield(theta,'sigma')
    error("rnd_lnormal:params","theta.c, theta.mu, and theta.sigma are needed.");
end
r = theta.c + lognrnd(theta.mu, theta.sigma, N, 1);
end