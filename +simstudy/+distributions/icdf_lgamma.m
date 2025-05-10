function x = icdf_lgamma(theta, u)
%ICDF_LGAMMA  Quantile function for the shifted log-gamma (Pearson III) distribution.
%
%   x = icdf_lgamma(theta, u)
%
%   Inputs
%       theta : struct with fields
%               .a  - shape  (a > 0)
%               .b  - scale  (b > 0)          ← log-scale factor
%               .c  - shift  (real)           ← location
%       u     : numeric array, 0 < u < 1
%
%   Output
%       x     : numeric array, same size as u
%
%   Derivation
%     Let Y ~ Gamma(a,1).  Define X = c + exp(b·Y).
%     Then  F_X(x) = P[X ≤ x] = P[Y ≤ (1/b)·log(x-c)].
%     Therefore  F^{-1}(u) = c + exp( b · G^{-1}(u) ),
%     where G^{-1} is the inverse CDF of Gamma(a,1).

arguments
    theta struct
    u {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
end

% unpack and validate parameters
a = theta.a;
b = theta.b;
c = theta.c;

if a <= 0 || b <= 0
    error("icdf_lgamma:InvalidParam","a and b must be positive.");
end

% inverse transform

g = gaminv(u, b, 1);        % quantile of Gamma(a,1)
x = c + a .* g;
end