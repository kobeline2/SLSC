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

lo = eps;                 % lower bound (>=0)
hi = theta.a * 200;    % heuristic upper bound

% ---- expand hi until F(hi) ≥  max(u) --------------------------------
while F(hi) < max(u)
    hi = hi * 2;
    if hi > 1e8
        error("icdf_sqrtet:NoBracket", ...
              "Cannot bracket root (hi grew beyond 1e8)");
    end
end

% ---- allocate output -------------------------------------------------
x = NaN(size(u));

% ---- solve for each p -----------------------------------------------
for k = 1:numel(u)
    p  = u(k);
    if p <= F(lo)    % ここは理論的には起こらないが安全チェック
        warning("icdf_sqrtet:BelowSupport", ...
                "u=%.4g is below CDF(lo). Return NaN.", p);
        continue
    end
    try
        x(k) = fzero(@(z) F(z) - p, [lo, hi]);
    catch ME
        warning("icdf_sqrtet:fzeroFail","%s  (u=%.4g)", ME.message, p);
        x(k) = NaN;
    end
end
end