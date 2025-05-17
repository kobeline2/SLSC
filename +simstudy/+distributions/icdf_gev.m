function x = icdf_gev(theta, u)
%ICDF_GEV  Quantile function (inverse CDF) of the GEV distribution.
%
%   x = icdf_gev(theta, u)
%
%   Inputs
%       theta : struct with fields
%               .k     - shape   (real)
%               .sigma - scale   (sigma > 0)
%               .mu    - location
%       u     : numeric vector/array in (0,1)
%
%   Output
%       x     : numeric array of the same size as u
%
%   The implementation follows the standard GEV quantile formulas:
%       k ≠ 0 :  x = μ + σ * ( ( -log(u) ).^(-k) - 1 ) / k
%       k = 0 :  x = μ - σ * log( -log(u) )     (Gumbel limit)

arguments
    theta struct
    u {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
end

% unpack parameters
k     = theta.k;
sigma = theta.sigma;
mu    = theta.mu;



% basic validation
if sigma <= 0
    error("icdf_gev:InvalidScale","sigma must be positive.");
end
x = gevinv(u, k, sigma, mu);

% % main formula if you cannot use gevinv.
% if abs(k) > 1e-12           % regular case (k ≠ 0)
%     x = mu + sigma .* ( (-log(u)).^(-k) - 1 ) ./ k;
% else                         % k → 0 ⇒ Gumbel
%     x = mu - sigma .* log(-log(u));
% end
end