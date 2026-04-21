function y = cdf_lp3(x, theta)
%CDF_LP3 CDF of the log-Pearson type III distribution.

arguments
    x       {mustBeNumeric}
    theta   struct
end

a = theta.a;
b = theta.b;
c = theta.c;

y = zeros(size(x));
if a <= 0 || b <= 0
    y(:) = NaN;
    return;
end

idx = x > exp(c);
z = (log(x(idx)) - c) ./ a;
y(idx) = gamcdf(z, b, 1);
end
