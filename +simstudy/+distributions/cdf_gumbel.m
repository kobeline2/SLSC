function y = cdf_gumbel(x, theta)

y = exp(-exp(-(x - theta.alpha) ./ theta.beta));

end
