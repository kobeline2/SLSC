function x = icdf_normal(u, theta)
x = norminv(u, theta.mu, theta.sigma);
end
