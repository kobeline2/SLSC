function x = icdf_exponential(u, theta)

x = expinv(u, theta.mu) + theta.c;
end
