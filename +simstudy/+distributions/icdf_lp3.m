function x = icdf_lp3(u, theta)
%ICDF_LP3 Quantile function for the log-Pearson type III distribution.
%
% Parameterisation:
%   log(X) = c + aY,  Y ~ Gamma(shape=b, scale=1), a > 0.

arguments
    u       {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
    theta   struct
end

a = theta.a;
b = theta.b;
c = theta.c;

if a <= 0 || b <= 0
    error("icdf_lp3:InvalidParam", "a and b must be positive.");
end

g = gaminv(u, b, 1);
x = exp(c + a .* g);
end
