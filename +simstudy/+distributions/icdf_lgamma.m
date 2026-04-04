function x = icdf_lgamma(u, theta)
%ICDF_LGAMMA Quantile function for the shifted gamma / Pearson III distribution.
%
%   x = icdf_lgamma(u, theta)
%
%   Inputs
%       theta : struct with fields
%               .a  - scale  (a > 0)
%               .b  - shape  (b > 0)
%               .c  - shift  (real)           ← location
%       u     : numeric array, 0 < u < 1
%
%   Output
%       x     : numeric array, same size as u
%
%   Parameterisation
%     X = c + aY,  Y ~ Gamma(shape=b, scale=1)
%     Therefore F^{-1}(u) = c + a * G^{-1}(u; b, 1).

arguments
    u {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
    theta struct
end

a = theta.a;
b = theta.b;
c = theta.c;

if a <= 0 || b <= 0
    error("icdf_lgamma:InvalidParam","a and b must be positive.");
end

g = gaminv(u, b, 1);
x = c + a .* g;
end
