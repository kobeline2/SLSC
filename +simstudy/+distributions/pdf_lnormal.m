function y = pdf_lnormal(x, theta)
% PDF of the shifted 3-parameter lognormal distribution.

y = lognpdf(x-theta.c, theta.mu, theta.sigma);

end
