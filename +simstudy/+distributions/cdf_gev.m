function y = cdf_gev(x, theta)

y = gevcdf(x, theta.k, theta.sigma, theta.mu);

end
