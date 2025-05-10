function ll = loglike_exponential(x, theta)
% Log-likelihood of the shifted log-gamma distribution
%

arguments
    x       {mustBeNumeric}
    theta   struct
end

ll = sum(log(simstudy.distributions.pdf("exponential", x, theta)));

end