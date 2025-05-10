function x = icdf_exponential(theta, u)

x = expinv(u, theta.mu) + theta.c;
end