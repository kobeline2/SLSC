function y = pdf_lp3(x, theta)
%PDF_LP3 PDF of the log-Pearson type III distribution.
%
% Parameterisation:
%   log(X) = c + aY,  Y ~ Gamma(shape=b, scale=1), a > 0.

arguments
    x       {mustBeNumeric}
    theta   struct
end

a = theta.a;
b = theta.b;
c = theta.c;

y = zeros(size(x));
if a <= 0 || b <= 0
    y(:) = NaN;
    return;
end

idx = x > exp(c);
z = (log(x(idx)) - c) ./ a;
y(idx) = z.^(b - 1) .* exp(-z) ./ (a .* x(idx) .* gamma(b));
end
