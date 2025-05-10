function  y = pdf_lgamma(x, theta)
% PDF of the shifted log-gamma distribution
%
%   Constraint: all(x) > theta.c

arguments
    x       {mustBeNumeric}
    theta   struct
end

% --- support check --------------------------------------------------
if any(x <= theta.c)
    warning("simstudy:pdf_lgamma:outOfSupport", ...
        "Input x must satisfy x > theta.c (theta.c = %g).", theta.c);
end

% --- pdf computation ------------------------------------------------
C = (x - theta.c)/theta.a;
den = theta.a * gamma(theta.b);
y = C.^(theta.b-1) .* exp(-C) / den;
y(x <= theta.c) = 0;            % assign 0 density to out-of-support points

end