function x = icdf_sqrtet(theta, u)
% Inverse CDF for the SQRT-ET distribution
% theta = struct('a',a,'b',b)   % 2-parameter
% u     = vector of uniform(0,1) values

arguments
    theta  struct
    u      {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
end

% CDF handle (your existing CDF implementation)
F = @(z) simstudy.distributions.cdf("sqrtet", z, theta);

lo = 0;                 % lower bound (>=0)
hi = theta.a * 200;    % heuristic upper bound

x = arrayfun(@(p) ...
        fzero(@(z) F(z) - p, [lo, hi]), ...
        u);
end