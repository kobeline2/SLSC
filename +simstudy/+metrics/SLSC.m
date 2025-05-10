function val = SLSC(obs, fitRes)
% Standard Least-Squares Criterion for goodness-of-fit.
%   data   : column vector of observations
%   fitRes : struct with .model, .theta (MLE), etc.

% CONSTANTS
Q = 0.01;
ALPHA = 0.4;
BETA = 0.2;

p = fitRes.theta;
% specify the position and scale parameters.
switch fitRes.model
    case 'normal'
        sv = @(x) (x - p.mu) / p.sigma; 
    case 'lgamma'
        sv = @(x) (x - p.a) / exp(p.b); 
    case 'sqrtet'
        % sv = @(x) -exp(p(1))*(1+sqrt(exp(p(2))*x))*exp(-sqrt(exp(p(2))*x));
        sv = @(x) p.b * x;
    case 'gumbel'
        sv = @(x) (x - p.alpha) / p.beta; 
    case 'gev'
        sv = @(x) (x - p.mu) / p.sigma; % p = (k, sigma, mu)
    case 'lnormal'
        sv = @(x) real((log(x - p.c) - log(p.mu)) / p.sigma); % to be fixed
    case 'exponential'
        sv = @(x) (x - p.c) / p.mu; 
end

% preparation
N     = length(obs);
pp    = simstudy.util.plottingPosition(N, ALPHA, BETA);
% calculate x -> s, x* -> s* (ref.Kuzuha)
x     = sort(obs);
xStar = simstudy.distributions.icdf(fitRes.model, pp, fitRes.theta); 
s     = sv(x); 
sStar = sv(xStar);
sq    = quantile(s, [Q 1-Q]);
% calculate SLSC and corr
slsc  = sqrt(mean((s-sStar).^2))  / abs(sq(2)-sq(1));
corr_ = corr(s, sStar);
val = slsc; % TODO
end