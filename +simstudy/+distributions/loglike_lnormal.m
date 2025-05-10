function ll = loglike_lnormal(x, theta)
% Log-likelihood of the shifted log-gamma distribution
%

arguments
    x       {mustBeNumeric}
    theta   struct
end

ll = sum(log(simstudy.distributions.pdf("lnormal", x, theta)));

end