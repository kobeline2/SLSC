function x = icdf_normal(theta, u)
x = norminv(u, theta.mu, theta.sigma);
end