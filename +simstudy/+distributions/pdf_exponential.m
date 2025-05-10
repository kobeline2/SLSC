function y = pdf_exponential(x, theta)

y = exppdf(x-theta.c, theta.mu);

end