function ll = loglike_gumbel(x, theta)
% c = -\frac{x-\mu}{\sigma}
mu = theta.alpha;
sigma = theta.beta;
c = (mu-x) / sigma;
ll = sum(-log(sigma) + c - exp(c));

end