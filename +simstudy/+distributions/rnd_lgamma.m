function x = rnd_lgamma(theta, N)
% Random variates for the shifted gamma / Pearson III parameterisation:
%   X = c + aY,  Y ~ Gamma(shape=b, scale=1)

arguments
    theta struct
    N (1,1) {mustBeInteger, mustBePositive}
end

y = gamrnd(theta.b, 1, N, 1);
x = theta.c + theta.a * y;
end
