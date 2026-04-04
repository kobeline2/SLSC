function y = cdf_normal(x, theta)

y = normcdf(x, theta.mu, theta.sigma);

end
