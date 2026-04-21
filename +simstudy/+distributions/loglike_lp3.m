function ll = loglike_lp3(x, theta)
%LOGLIKE_LP3 Log-likelihood of the log-Pearson type III distribution.

arguments
    x       {mustBeNumeric}
    theta   struct
end

a = theta.a;
b = theta.b;
c = theta.c;

if a <= 0 || b <= 0 || any(x <= exp(c))
    ll = -Inf;
    return;
end

z = (log(x) - c) ./ a;
ll = -log(a) - log(x) - gammaln(b) + (b - 1) .* log(z) - z;
ll = sum(ll);
end
