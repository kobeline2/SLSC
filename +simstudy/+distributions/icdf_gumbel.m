function x = icdf_gumbel(theta, u)

x = -log(-log(u))*theta.beta + theta.alpha;
end