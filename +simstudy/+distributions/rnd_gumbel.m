function r = rnd_gumbel(theta, N)
% theta: struct('alpha', \alpha, 'beta', \beta)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'alpha') || ~isfield(theta,'beta')
    error("rnd_gumbel:params","theta.alpha and theta.beta are needed.");
end
r = -evrnd(-theta.alpha, theta.beta, N, 1);
end