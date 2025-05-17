function v = loocv(obs, fitRes, opts)
%LOOCV  Leave-One-Out log-likelihood (brute force re-fit)
%
%   v = simstudy.metrics.loocv(obs, fitRes, opts)
%   opts.ignoreFail = true  (default)  % エラー発生時 NaN スキップ
%   opts.normalize   = true  → v = v/N
%
arguments
    obs (:,1) double
    fitRes struct          % not used (refit anyway)
    opts.ignoreFail logical = true
    opts.normalize logical = false
end

N  = numel(obs);
ll = zeros(N,1);

for i = 1:N                     % parfor 可
    dTr = obs;  dTr(i) = [];      % 学習データ = N-1
    try
        % 再フィット
        theta = simstudy.estimators.MLE(fitRes.model, dTr, []);
        % left-out likelihood
        ll(i) = simstudy.distributions.loglike(fitRes.model, obs(i), theta.theta);
    catch
        if ~opts.ignoreFail, rethrow(lasterror); end
        ll(i) = NaN;
    end
end

v = sum(ll, 'omitnan');                    % 合計
if opts.normalize, v = v / N; end
end