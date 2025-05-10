function ll = loglike_normal(x, theta)

v = theta.sigma^2;
ll = sum(-0.5*log(2*pi*v) - 0.5*(x-theta.mu).^2/v);

end