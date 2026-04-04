function y = cdf_exponential(x, theta)

y = expcdf(x - theta.c, theta.mu);
y(x < theta.c) = 0;

end
