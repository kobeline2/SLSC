function x = icdf_lnormal(theta, u)

x = logninv(u, theta.mu, theta.sigma) + theta.c;
end