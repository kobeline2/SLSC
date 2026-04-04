function y = cdf_sqrtet(x, theta)
a = theta.a;
b = theta.b;
y = exp(-a * (1+sqrt(b*x)) .* exp(-sqrt(b*x)));
end
