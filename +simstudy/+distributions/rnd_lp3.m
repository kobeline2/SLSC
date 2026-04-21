function x = rnd_lp3(theta, N)
%RND_LP3 Random variates for the log-Pearson type III distribution.
%
% Parameterisation:
%   log(X) = c + aY,  Y ~ Gamma(shape=b, scale=1), a > 0.

arguments
    theta   struct
    N       (1,1) {mustBeInteger, mustBePositive}
end

y = gamrnd(theta.b, 1, N, 1);
x = exp(theta.c + theta.a .* y);
end
