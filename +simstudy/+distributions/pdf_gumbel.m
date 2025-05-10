function y = pdf_gumbel(x, theta)
mu = theta.alpha;
sigma = theta.beta;
c = (mu-x) / sigma;
y = exp(c - exp(c))/sigma;

end