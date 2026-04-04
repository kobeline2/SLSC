function ll = loglike_lgamma(x, theta)
% Log-likelihood of the shifted gamma / Pearson III distribution.

arguments
    x       {mustBeNumeric}
    theta   struct
end

a = theta.a;
b = theta.b;
c = theta.c;
C = (x-c) / a;
ll = -log(a) - gammaln(b) + (b-1)*log(C) -C;
ll(x <= c) = -Inf;
ll = sum(ll);

end
