function y = pdf_gev(x, theta)

y = gevpdf(x, theta.k, theta.sigma, theta.mu);

end