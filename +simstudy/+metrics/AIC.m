function aic = AIC(obs, fitRes)
% Akaike Information Criterion: 2k - 2logL

k       = numel(fieldnames(fitRes.theta));        % number of free params
loglik  = simstudy.distributions.loglike( ...
            fitRes.model, obs, fitRes.theta);

aic = 2*k - 2*loglik;

end