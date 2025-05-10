function ll = loglike_lgamma(x, theta)
% Log-likelihood of the shifted log-gamma distribution
%
%   Constraint: all(x) > theta.c

arguments
    x       {mustBeNumeric}
    theta   struct
end

% --- support check --------------------------------------------------
if any(x <= theta.c)
    warning("simstudy:loglike_lgamma:outOfSupport", ...
        "Input x must satisfy x > theta.c (theta.c = %g).", theta.c);
end
a = theta.a;
b = theta.b;
c = theta.c;
C = (x-c) / a;
ll = -log(a) - gammaln(b) + (b-1)*log(C) -C;
ll(x <= c) = -Inf;
ll = sum(ll);

end