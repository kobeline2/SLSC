function ll = loglike_gev(x, theta)
%LOGLIKE_GEV  Log-likelihood for the GEV distribution.
%
%   ll = loglike_gev(theta, data)
%
%   theta : struct with fields
%       .k     - shape   (real)
%       .sigma - scale   (sigma > 0)
%       .mu    - location
%   data  : numeric vector of observations
%
%   The function returns -Inf if the support constraint
%   1 + k*(x - mu)/sigma > 0 is violated for any sample.

% --------------------- input validation ------------------------------
arguments
    x     {mustBeNumeric, mustBeVector}
    theta struct
end

k     = theta.k;
sigma = theta.sigma;
mu    = theta.mu;

% scale must be positive
if sigma <= 0
    ll = -Inf;
    return
end

% --------------------- reduced variate -------------------------------
t = 1 + k .* ((x - mu) ./ sigma);

% support check
if any(t <= 0)
    ll = -Inf;
    return
end

% --------------------- log-pdf evaluation ----------------------------
if abs(k) > 1e-12          % regular case (k ≠ 0)
    logPdf = -log(sigma) - (1 + 1./k) .* log(t) - t.^(-1./k);
else                        % limit k → 0 ⇒ Gumbel
    y      = (x - mu) ./ sigma;
    logPdf = -log(sigma) - y - exp(-y);
end

ll = sum(logPdf);
end