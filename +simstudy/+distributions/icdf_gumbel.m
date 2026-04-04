function x = icdf_gumbel(u, theta)

x = -log(-log(u))*theta.beta + theta.alpha;
end
