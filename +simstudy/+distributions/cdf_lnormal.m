function y = cdf_lnormal(x, theta)
% CDF of the shifted 3-parameter lognormal distribution.

y = logncdf(x - theta.c, theta.mu, theta.sigma);
y(x <= theta.c) = 0;

end
