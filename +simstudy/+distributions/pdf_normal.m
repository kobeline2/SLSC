function y = pdf_normal(x, theta)

c = sqrt(2*pi)*theta.sigma;
y = exp(-0.5*((x-theta.mu)/theta.sigma).^2) / c;

end