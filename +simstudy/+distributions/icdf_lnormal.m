function x = icdf_lnormal(u, theta)
% Quantile function of the shifted 3-parameter lognormal distribution.

x = logninv(u, theta.mu, theta.sigma) + theta.c;
end
