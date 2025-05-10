function y = pdf_lnormal(x, theta)

y = lognpdf(x-theta.c, theta.mu, theta.sigma);

end