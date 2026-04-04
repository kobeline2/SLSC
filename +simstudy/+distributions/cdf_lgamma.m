function y = cdf_lgamma(x, theta)
% CDF of the shifted gamma / Pearson III distribution.

z = (x - theta.c) ./ theta.a;
y = gamcdf(z, theta.b, 1);
y(x <= theta.c) = 0;

end
