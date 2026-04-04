function y = pdf_lgamma(x, theta)
% PDF of the shifted gamma / Pearson III distribution.
% Parameterisation:
%   X = c + aY,  Y ~ Gamma(shape=b, scale=1)

arguments
    x       {mustBeNumeric}
    theta   struct
end

C = (x - theta.c)/theta.a;
den = theta.a * gamma(theta.b);
y = C.^(theta.b-1) .* exp(-C) / den;
y(x <= theta.c) = 0;

end
