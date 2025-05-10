function y = cdf_sqrtet(theta, x)
a = exp(theta.a);
b = exp(theta.b);
y = exp(-a * (1+sqrt(b*x)) .* exp(-sqrt(b*x)));
end