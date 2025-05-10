function ce = Xentropy(obs, fitRes)
% Cross-entropy = -mean log p_model(x)
loglik = simstudy.distributions.loglike( ...
           fitRes.model, obs, fitRes.theta);
ce = -loglik / numel(obs);
end